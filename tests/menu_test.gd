extends SceneTree

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
	var menu = load("res://main.tscn").instantiate()
	menu.save_path = test_path
	root.add_child(menu)
	current_scene = menu
	return menu

func run_checks() -> void:
	var menu = make_menu()
	check(menu.load_button.disabled, "Load disabled without saved game")
	var saved := ConfigFile.new()
	saved.set_value("progress", "money", 734)
	saved.set_value("progress", "water_count", 6)
	saved.set_value("progress", "green_tea_count", 2)
	saved.set_value("progress", "cans", 8)
	saved.save(test_path)
	menu.free()
	menu = make_menu()
	check(not menu.load_button.disabled, "Load enabled with valid save")
	menu.load_button.pressed.emit()
	await process_frame
	var game = current_scene
	check(game.money == 734 and game.water_count == 6 and game.green_tea_count == 2, "Load Game restores saved progress")
	game.free()
	menu = make_menu()
	menu.get_node("MenuBox/NewGameButton").pressed.emit()
	var backup_path: String = menu.last_backup_path
	await process_frame
	game = current_scene
	check(game.money == 0 and game.drinks == 0 and not game.quest_reward_claimed, "New Game starts fresh")
	var backup := ConfigFile.new()
	check(backup.load(backup_path) == OK and backup.get_value("progress", "money") == 734, "New Game preserves previous save in separate backup")
	var fresh := ConfigFile.new()
	check(fresh.load(test_path) == OK and fresh.get_value("progress", "money") == 0, "New Game creates fresh current save")
	game.money = 500
	game.click_stack = 4
	press_escape()
	await process_frame
	check(paused and game.pause_menu.overlay.visible, "ESC opens pause menu and pauses game")
	game._on_earn_button_pressed()
	game._on_shop_button_pressed()
	check(game.click_stack == 4 and game.money == 500, "Paused gameplay cannot change progress")
	game.pause_menu.get_node("Overlay/Card/Margin/Buttons/SaveButton").pressed.emit()
	var manual := ConfigFile.new()
	check(manual.load(test_path) == OK and manual.get_value("progress", "money") == 500 and manual.get_value("progress", "click_stack") == 4, "Save button persists exact current progress while paused")
	check(game.pause_menu.status.text == "저장했습니다." and paused, "Save confirms success without resuming")
	game.pause_menu.resume_button.pressed.emit()
	check(not paused and not game.pause_menu.overlay.visible, "Continue resumes gameplay")
	game._on_shop_button_pressed()
	press_escape()
	await create_timer(0.7).timeout
	check(game.inserting_coin and not game.result_overlay.visible, "Coin animation stays paused under ESC menu")
	press_escape()
	await game.coin_tween.finished
	check(not paused and not game.inserting_coin and not game.result_overlay.visible, "ESC resumes dispensing and completes without a popup")
	press_escape()
	await process_frame
	check(paused and game.pause_menu.overlay.visible, "Pause also works over drink result")
	game.pause_menu.resume_button.pressed.emit()
	game.close_button.pressed.emit()
	press_escape()
	await process_frame
	game.save_path = "res://.godot/missing_directory/menu_test.cfg"
	game.pause_menu.get_node("Overlay/Card/Margin/Buttons/QuitButton").pressed.emit()
	check(paused and game.pause_menu.status.text.contains("종료하지 않았습니다"), "Failed save prevents quitting")
	game.save_path = test_path
	game.pause_menu.resume_button.pressed.emit()
	game.free()
	DirAccess.remove_absolute(test_path)
	DirAccess.remove_absolute(backup_path)
	print("Menu checks: %d failures" % failures)
	quit(1 if failures else 0)
