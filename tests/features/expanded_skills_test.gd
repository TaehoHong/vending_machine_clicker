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
		var folder: String = "res://.godot/test_artifacts/expanded_skills_test"
		DirAccess.make_dir_recursive_absolute(folder)
		root.get_texture().get_image().save_png(folder.path_join("%s.png" % name))


func run_checks() -> void:
	var game = FIXTURE.create_game(root)
	FIXTURE.store_for(game).path = "res://.godot/expanded_skills_%d.cfg" % Time.get_ticks_usec()
	check(
		(
			game.shop_button.tooltip_text.is_empty()
			and not game.has_node("SlotHint/Description")
			and game.get_node("SlotHint/Price").text == "100"
		),
		"Price is Gold and both extra hints are removed"
	)
	game.session.cans = 200
	game._on_skill_button_pressed()
	var tree = game.get_node("InfoOverlay/Card/SkillTree")
	game._on_unlock_drink_requested(5)
	check(
		not game.session.drink_unlocked(5) and game.session.cans == 200,
		"Prerequisite gates prevent skipping branches"
	)
	await capture("tree_top_locked")
	for i in tree.ORDER:
		var before: int = game.session.cans
		tree.get_unlock_button(i).pressed.emit()
		check(
			(
				game.session.drink_unlocked(i)
				and game.session.cans == before - game.session.DRINK_DATA[i].cost
			),
			"Each tree button unlocks the correct drink and charges correct cans"
		)
		game._on_unlock_drink_requested(i)
		check(
			game.session.cans == before - game.session.DRINK_DATA[i].cost,
			"Duplicate unlock does not consume cans"
		)
	await capture("tree_top")
	tree.select_drink(14)
	await capture("energy_selection")
	game._on_info_close_pressed()
	var seen: Dictionary = {}
	seed(20261017)
	for i in range(1000):
		seen[game.session._roll_drink()] = true
	check(seen.size() == 15, "All fifteen unlocked drinks can appear")
	var old_miss: float = game.session.miss_chance()
	game.session._apply_drink(3)
	check(
		is_equal_approx(game.session.miss_chance(), old_miss - 0.005),
		"Vitamin reduces miss chance by 0.5 percentage points"
	)
	var old_bonus: int = game.session.coin_bonus()
	game.session._apply_drink(4)
	check(game.session.coin_bonus() == old_bonus + 3, "Apple adds 3 discovery Gold")
	game.session._apply_drink(5)
	check(
		is_equal_approx(game.session.reward_multiplier(), 1.01),
		"Orange adds 1 percent final reward"
	)
	old_bonus = game.session.coin_bonus()
	game.session._apply_drink(6)
	check(game.session.coin_bonus() == old_bonus + 5, "Cola adds 5 discovery Gold")
	game.session._apply_drink(7)
	check(
		is_equal_approx(game.session.reward_multiplier(), 1.03), "Fanta adds 2 percent final reward"
	)
	var old_clicks: int = game.session.clicks_required()
	for i in range(4):
		game.session._apply_drink(8)
	check(
		game.session.clicks_required() == old_clicks - 1,
		"Four sprites reduce required clicks by one"
	)
	check(
		game.session.calculate_reward(1000) == floori((1000 + game.session.coin_bonus()) * 1.03),
		"Percentage effects apply to actual payouts"
	)
	game._on_ability_button_pressed()
	await capture("ability_top")
	game.get_node("InfoOverlay/Card/Catalog").scroll_vertical = 2000
	await capture("ability_bottom")
	game._on_info_close_pressed()
	for i in range(3, 15):
		game.drink_dispense_fx.call(
			"begin", load(game.session.DRINK_DATA[i].asset), Color(game.session.DRINK_DATA[i].color)
		)
		check(
			game.drink_dispense_fx.art.texture != null,
			"Every drink has its own dispensing illustration"
		)
	game.drink_dispense_fx.hide()
	var saved_cans: int = game.session.cans
	game._save_progress()
	var path: String = FIXTURE.store_for(game).path
	game.free()
	game = FIXTURE.create_game(root)
	FIXTURE.store_for(game).path = path
	FIXTURE.store_for(game).load_into(game.session)
	game._refresh_ui()
	check(
		(
			game.session.cans == saved_cans
			and game.session.drink_count(8) == 4
			and game.session.drink_count(3) == 1
		),
		"New drink counts and spent balance survive reload"
	)
	for i in range(2, 15):
		check(game.session.drink_unlocked(i), "All branch unlocks survive reload")
	game.free()
	DirAccess.remove_absolute(path)
	print("Expanded skill checks: %d failures" % failures)
	quit(1 if failures else 0)
