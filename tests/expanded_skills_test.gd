extends SceneTree

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
		root.get_texture().get_image().save_png("res://design/godot-applied/expanded_%s.png" % name)
func run_checks() -> void:
	var game = load("res://Game.tscn").instantiate()
	game.save_path = "res://.godot/expanded_skills_%d.cfg" % Time.get_ticks_usec()
	root.add_child(game)
	check(game.shop_button.tooltip_text.is_empty() and not game.has_node("SlotHint/Description") and game.get_node("SlotHint/Price").text == "100 Gold 투입", "Price is Gold and both extra hints are removed")
	game.cans = 200
	game._on_skill_button_pressed()
	var tree = game.get_node("InfoOverlay/Card/SkillTree")
	game._on_unlock_drink_requested(5)
	check(not game.drink_unlocked(5) and game.cans == 200, "Prerequisite gates prevent skipping branches")
	await capture("tree_top_locked")
	for i in range(2,9):
		var before: int = game.cans
		tree.get_unlock_button(i).pressed.emit()
		check(game.drink_unlocked(i) and game.cans == before - game.DRINK_DATA[i].cost, "Each tree button unlocks the correct drink and charges correct cans")
		game._on_unlock_drink_requested(i)
		check(game.cans == before - game.DRINK_DATA[i].cost, "Duplicate unlock does not consume cans")
	await capture("tree_top")
	tree.scroll_vertical = 1000
	await capture("tree_bottom")
	game._on_info_close_pressed()
	var seen: Dictionary = {}
	seed(20261017)
	for i in range(1000):
		seen[game._roll_drink()] = true
	check(seen.size() == 9, "All nine unlocked drinks can appear")
	var old_miss: float = game.miss_chance()
	game._apply_drink(3)
	check(is_equal_approx(game.miss_chance(),old_miss-0.005), "Vitamin reduces miss chance by 0.5 percentage points")
	var old_bonus: int = game.coin_bonus()
	game._apply_drink(4)
	check(game.coin_bonus() == old_bonus+3, "Apple adds 3 discovery Gold")
	game._apply_drink(5)
	check(is_equal_approx(game.reward_multiplier(),1.01), "Orange adds 1 percent final reward")
	old_bonus = game.coin_bonus()
	game._apply_drink(6)
	check(game.coin_bonus() == old_bonus+5, "Cola adds 5 discovery Gold")
	game._apply_drink(7)
	check(is_equal_approx(game.reward_multiplier(),1.03), "Fanta adds 2 percent final reward")
	var old_clicks: int = game.clicks_required()
	for i in range(4):
		game._apply_drink(8)
	check(game.clicks_required() == old_clicks-1, "Four sprites reduce required clicks by one")
	check(game.calculate_reward(1000) == floori((1000+game.coin_bonus())*1.03), "Percentage effects apply to actual payouts")
	game._on_ability_button_pressed()
	await capture("ability_top")
	game.get_node("InfoOverlay/Card/Catalog").scroll_vertical = 2000
	await capture("ability_bottom")
	game._on_info_close_pressed()
	for i in range(3,9):
		game.last_drink = i
		game._update_result()
		check(game.result_title.text.contains(game.DRINK_DATA[i].name) and game.result_art.texture != null, "Every new drink has an acquisition result and illustration")
	game.result_overlay.show()
	await capture("sprite_result")
	game._on_result_close_pressed()
	var saved_cans: int = game.cans
	game._save_progress()
	var path: String = game.save_path
	game.free()
	game = load("res://Game.tscn").instantiate()
	game.save_path = path
	root.add_child(game)
	check(game.cans == saved_cans and game.drink_count(8) == 4 and game.drink_count(3) == 1, "New drink counts and spent balance survive reload")
	for i in range(2,9):
		check(game.drink_unlocked(i), "All branch unlocks survive reload")
	game.free()
	DirAccess.remove_absolute(path)
	print("Expanded skill checks: %d failures" % failures)
	quit(1 if failures else 0)
