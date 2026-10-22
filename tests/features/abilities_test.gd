extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")

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
		var folder: String = "res://.godot/test_artifacts/abilities_test"
		DirAccess.make_dir_recursive_absolute(folder)
		root.get_texture().get_image().save_png(folder.path_join("%s.png" % name))


func run_checks() -> void:
	var game = FIXTURE.create_game(root)
	FIXTURE.store_for(game).path = "res://.godot/ability_test_%d.cfg" % Time.get_ticks_usec()
	check(not game.has_node("ShopPanel"), "Old collection panel removed")
	game.session.quest_clicks = 10
	game._on_quest_complete_button_pressed()
	check(
		(
			game.session.quest_reward_claimed
			and not game.session.can_quest_reward_claimed
			and game.quest_progress.visible
		),
		"First quest advances to can collection without collapsing"
	)
	game._on_quest_complete_button_pressed()
	check(
		game.session.money == 5000 and not game.session.can_quest_reward_claimed,
		"Can quest cannot be claimed early"
	)
	for drink in [0, 1, 0, 1, 1]:
		var before: int = game.session.cans
		game.session._apply_drink(drink)
		check(game.session.cans == before + 1, "Every drink grants exactly one empty can")
	game._refresh_ui()
	check(
		(
			game.can_count_label.text == "빈캔 5"
			and game.session.water_count == 2
			and game.session.green_tea_count == 3
		),
		"HUD shows total cans independently from drink type"
	)
	check(
		not game.quest_complete_button.disabled and game.quest_complete_button.visible,
		"Five cans unlock second quest reward"
	)
	await capture("hud")
	game.get_node("Navigation/AbilityButton").pressed.emit()
	var screen = game.get_node("InfoOverlay/Card/SkillTree")
	screen.select_drink(0)
	check(
		game.info_overlay.visible and screen.detail_count.text.contains("2"),
		"Selected water shows two acquired cans"
	)
	screen.select_drink(1)
	check(screen.detail_count.text.contains("3"), "Selected tea shows three acquired cans")
	screen.summary_button.pressed.emit()
	check(
		screen.summary_panel.visible and screen.summary_label.text.contains("+4 Gold"),
		"Ability summary shows actual combined bonuses"
	)
	var clicks_before: int = game.session.click_stack
	game._on_earn_button_pressed()
	check(game.session.click_stack == clicks_before, "Ability window blocks underlying search")
	await capture("ability")
	screen.close_button.pressed.emit()
	check(
		not game.info_overlay.visible and not game.earn_button.disabled,
		"Closing ability restores input"
	)
	game.get_node("Navigation/AbilityButton").pressed.emit()
	check(
		game.info_overlay.visible and not game.get_node("InfoOverlay/Card/Catalog").visible,
		"Ability button opens the integrated drink screen"
	)
	await capture("skill")
	screen.close_button.pressed.emit()
	game._on_quest_complete_button_pressed()
	game._on_quest_complete_button_pressed()
	check(
		(
			game.session.money == 5100
			and game.session.cans == 5
			and game.session.can_quest_reward_claimed
			and game.quest_panel.size.y >= 64
		),
		"Can quest pays once, keeps cans, and collapses after both quests"
	)
	check(game.feedback_label.text.is_empty(), "Quest completion does not show bottom text")
	var saved := ConfigFile.new()
	check(
		(
			saved.load(FIXTURE.store_for(game).path) == OK
			and saved.get_value("progress", "can_quest_reward_claimed") == true
		),
		"New quest completion is saved"
	)
	await capture("completed")
	DirAccess.remove_absolute(FIXTURE.store_for(game).path)
	game.free()
	print("Ability and can checks: %d failures" % failures)
	quit(1 if failures else 0)
