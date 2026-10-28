extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")
const DESIGN = preload("res://src/shared/ui/design_view.gd")


class BackupFailureStore extends "res://src/integrations/saves/progress_store.gd":

	var fail_backup: bool = true


	func backup() -> String:
		return "" if fail_backup else super.backup()

var failures: int = 0
var test_path: String = "res://.godot/menu_test_%d.cfg" % Time.get_ticks_usec()


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _initialize() -> void:
	call_deferred("run_checks")


func press_escape() -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	Input.parse_input_event(event)


func make_menu():
	var menu = load("res://src/app/main.tscn").instantiate()
	menu.save_path = test_path
	root.add_child(menu)
	current_scene = menu
	return menu


func run_checks() -> void:
	var menu = make_menu()
	check(menu.view.load_button.disabled, "Load disabled without saved game")
	check(
		menu.view.new_game_button.get_global_rect().position.y
		< menu.view.load_button.get_global_rect().position.y,
		"Without a save, New Game appears above Continue"
	)
	var start_button: Button = menu.view.new_game_button
	check(start_button.has_focus(), "New Game starts with keyboard focus")
	var menu_box: Control = DESIGN.shape(menu.view.get_node("Design"), "MenuBox")
	menu.view._open_settings()
	check(not menu_box.visible, "Title settings show the world without the title menu")
	menu.view.settings.go_back()
	check(menu_box.visible, "Leaving title settings restores the menu")
	var start_bounds: Rect2 = start_button.get_global_rect()
	var move := InputEventMouseMotion.new()
	move.position = start_bounds.get_center()
	root.push_input(move, true)
	await process_frame
	var press := InputEventMouseButton.new()
	press.position = start_bounds.get_center()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	root.push_input(press, true)
	await process_frame
	check(start_button.get_global_rect() == start_bounds, "Pressed feedback keeps its hit area")
	press = press.duplicate()
	press.pressed = false
	root.push_input(press, true)
	await process_frame
	check(menu.view.has_node("VendingMachine"), "Click passes through the A frame and starts play")
	menu.free()
	menu = make_menu()
	var saved := ConfigFile.new()
	saved.set_value("progress", "money", 734)
	saved.set_value("progress", "water_count", 6)
	saved.set_value("progress", "green_tea_count", 2)
	saved.set_value("progress", "cans", 8)
	saved.save(test_path)
	menu.free()
	menu = make_menu()
	check(not menu.view.load_button.disabled, "Load enabled with valid save")
	check(
		menu.view.load_button.get_global_rect().position.y
		< menu.view.new_game_button.get_global_rect().position.y,
		"With a save, Continue appears above New Game"
	)
	menu.view.load_button.pressed.emit()
	await process_frame
	var game = menu.view
	check(
		(
			game.session.money == 734
			and game.session.water_count == 6
			and game.session.green_tea_count == 2
		),
		"Load Game restores saved progress"
	)
	menu.free()
	menu = make_menu()
	var failing_store := BackupFailureStore.new(test_path)
	menu.store = failing_store
	var saved_summary: String = menu.view.save_summary.text
	menu.view.new_game_button.pressed.emit()
	check(not menu.starting_game, "Backup failure leaves the current save and menu intact")
	check(menu.view.save_summary.text == saved_summary, "Backup error preserves the save summary")
	check(
		menu.view.menu_status.text == "백업 실패" and menu.view.menu_status.visible,
		"Backup failure has a separate visible status"
	)
	var retry_label: Label = DESIGN.shape(menu.view.new_game_button.get_parent(), "Label")
	check(retry_label.text == "다시 시도", "Failed backup offers the original retry action")
	menu.view._open_settings()
	check(not menu.view.menu_status.visible, "Title settings hide the prior backup warning")
	menu.view.settings.go_back()
	check(menu.view.menu_status.visible, "Returning from settings preserves the backup warning")
	failing_store.fail_backup = false
	menu.view.new_game_button.pressed.emit()
	var backup_path: String = menu.last_backup_path
	await process_frame
	game = menu.view
	check(
		(
			game.session.money == 0
			and game.session.drinks == 0
			and not game.session.quest_reward_claimed
		),
		"New Game starts fresh"
	)
	var backup := ConfigFile.new()
	check(
		backup.load(backup_path) == OK and backup.get_value("progress", "money") == 734,
		"New Game preserves previous save in separate backup"
	)
	var fresh := ConfigFile.new()
	check(
		fresh.load(test_path) == OK and fresh.get_value("progress", "money") == 0,
		"New Game creates fresh current save"
	)
	game.session.money = 500
	game.session.click_stack = 4
	press_escape()
	await process_frame
	check(paused and game.pause_menu.overlay.visible, "ESC opens pause menu and pauses game")
	game.pause_menu.show_save_status("저장하지 못했습니다. 다시 시도해주세요.", true)
	check(
		game.pause_menu.status.text == "저장하지 못했습니다.\n다시 시도해주세요."
		and game.pause_menu.status.get_theme_color("font_color").is_equal_approx(
			DESIGN.THEME.get_color("accent_color", "Label")
		),
		"Pause save failure uses the original two-line warning"
	)
	game.pause_menu.show_save_status("저장했습니다.", false)
	check(
		game.pause_menu.status.text == "저장했습니다."
		and game.pause_menu.status.get_theme_color("font_color").is_equal_approx(
			DESIGN.THEME.get_color("secondary_color", "Label")
		),
		"Successful save clears the previous warning presentation"
	)
	game._on_earn_button_pressed()
	game._on_shop_button_pressed()
	check(
		game.session.click_stack == 4 and game.session.money == 500,
		"Paused gameplay cannot change progress"
	)
	game.pause_menu.save_button.pressed.emit()
	var manual := ConfigFile.new()
	check(
		(
			manual.load(test_path) == OK
			and manual.get_value("progress", "money") == 500
			and manual.get_value("progress", "click_stack") == 4
		),
		"Save button persists exact current progress while paused"
	)
	check(
		game.pause_menu.status.text == "저장했습니다." and paused,
		"Save confirms success without resuming"
	)
	game.pause_menu.resume_button.pressed.emit()
	check(not paused and not game.pause_menu.overlay.visible, "Continue resumes gameplay")
	game._on_shop_button_pressed()
	press_escape()
	await create_timer(0.7).timeout
	check(
		game.session.inserting_coin and not game.result_overlay.visible,
		"Coin animation stays paused under ESC menu"
	)
	press_escape()
	await FIXTURE.wait_for_purchase_effects(game)
	check(
		not paused and not game.session.inserting_coin and not game.result_overlay.visible,
		"ESC resumes dispensing and completes without a popup"
	)
	press_escape()
	await process_frame
	check(paused and game.pause_menu.overlay.visible, "Pause also works over drink result")
	game.pause_menu.resume_button.pressed.emit()
	game.close_button.pressed.emit()
	press_escape()
	await process_frame
	menu.store.path = "res://.godot/missing_directory/menu_test.cfg"
	game.pause_menu.quit_button.pressed.emit()
	check(
		paused and game.pause_menu.status.text.contains("종료하지 않았습니다"),
		"Failed save prevents quitting"
	)
	menu.store.path = test_path
	game.pause_menu.resume_button.pressed.emit()
	menu.free()
	DirAccess.remove_absolute(test_path)
	DirAccess.remove_absolute(backup_path)
	print("Menu checks: %d failures" % failures)
	quit(1 if failures else 0)
