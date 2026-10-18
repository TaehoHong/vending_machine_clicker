extends SceneTree

class AbilityGame extends "res://game.gd":
	func _load_progress() -> void:
		pass

var failures: int = 0
func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run_checks")
func capture(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://design/godot-applied/cans_%s.png" % name)
func run_checks() -> void:
	var game = load("res://Game.tscn").instantiate()
	game.set_script(AbilityGame)
	game.save_path = "res://.godot/ability_test_%d.cfg" % Time.get_ticks_usec()
	root.add_child(game)
	check(not game.has_node("ShopPanel"), "Old collection panel removed")
	game.quest_clicks = 10
	game._on_quest_complete_button_pressed()
	check(game.quest_reward_claimed and not game.can_quest_reward_claimed and game.quest_progress.visible, "First quest advances to can collection without collapsing")
	game._on_quest_complete_button_pressed()
	check(game.money == 5000 and not game.can_quest_reward_claimed, "Can quest cannot be claimed early")
	for drink in [0,1,0,1,1]:
		var before: int = game.cans
		game._apply_drink(drink)
		check(game.cans == before + 1, "Every drink grants exactly one empty can")
	game._refresh_ui()
	check(game.can_count_label.text == "빈캔 5" and game.water_count == 2 and game.green_tea_count == 3, "HUD shows total cans independently from drink type")
	check(not game.quest_complete_button.disabled and game.quest_complete_button.visible, "Five cans unlock second quest reward")
	await capture("hud")
	game.get_node("Navigation/AbilityButton").pressed.emit()
	check(game.info_overlay.visible and game.get_node("InfoOverlay/Card/Catalog/Rows/Water/Count").text.contains("2") and game.get_node("InfoOverlay/Card/Catalog/Rows/Tea/Count").text.contains("3"), "Ability window shows counts by can type")
	check(game.get_node("InfoOverlay/Card/Summary").text.contains("+4 Gold"), "Ability window shows actual combined bonuses")
	var clicks_before: int = game.click_stack
	game._on_earn_button_pressed()
	check(game.click_stack == clicks_before, "Ability window blocks underlying search")
	await capture("ability")
	game.get_node("InfoOverlay/Card/CloseButton").pressed.emit()
	check(not game.info_overlay.visible and not game.earn_button.disabled, "Closing ability restores input")
	game.get_node("Navigation/SkillButton").pressed.emit()
	check(game.info_overlay.visible and not game.get_node("InfoOverlay/Card/Catalog").visible, "Skill button opens separate placeholder")
	await capture("skill")
	game.get_node("InfoOverlay/Card/CloseButton").pressed.emit()
	game._on_quest_complete_button_pressed()
	game._on_quest_complete_button_pressed()
	check(game.money == 5100 and game.cans == 5 and game.can_quest_reward_claimed and game.quest_panel.size.y >= 64, "Can quest pays once, keeps cans, and collapses after both quests")
	check(game.feedback_label.text.is_empty(), "Quest completion does not show bottom text")
	var saved := ConfigFile.new()
	check(saved.load(game.save_path) == OK and saved.get_value("progress", "can_quest_reward_claimed") == true, "New quest completion is saved")
	await capture("completed")
	DirAccess.remove_absolute(game.save_path)
	game.free()
	print("Ability and can checks: %d failures" % failures)
	quit(1 if failures else 0)
