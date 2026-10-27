extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")

class OutcomeSession:
	extends "res://src/game/game_session.gd"
	var empty: bool = false
	var doubled: bool = false
	var double_click: bool = false
	var forced_drink: int = 6

	func _search_is_empty() -> bool:
		return empty

	func _roll_double_reward() -> bool:
		return doubled

	func _roll_double_click() -> bool:
		return double_click

	func _roll_drink() -> int:
		return forced_drink


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
			and game.price_label.text == "100"
		),
		"Price is Gold and both extra hints are removed"
	)
	game.session.cans = 200
	game._on_skill_button_pressed()
	var tree = game.get_node("InfoOverlay/Card/SkillTree")
	game._on_unlock_drink_requested(5)
	check(
		game.session.drink_unlocked(5) and game.session.cans == 185,
		"Orange unlocks directly without lime"
	)
	await capture("tree_top_locked")
	for i in tree.ORDER:
		if i == 5:
			continue
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
	_check_new_rules()
	for index in range(15):
		for count in range(int(game.session.DRINK_DATA[index].max_enhancements) + 5):
			game.session._apply_drink(index)
	game._refresh_ui()
	game._on_ability_button_pressed()
	tree.select_drink(0)
	check(tree.detail_count.text.contains("15개"), "Overflow collection remains visible")
	check(tree.detail_count.text.contains("10/10"), "Applied strength is capped separately")
	check(tree.detail_status.text.contains("추첨 제외"), "Completed normal drinks explain exclusion")
	await capture("water_capped")
	tree.select_drink(6)
	check(tree.detail_status.text.contains("반복 등장"), "Fever drink remains repeatable")
	await capture("cola_repeatable")
	tree.summary_button.pressed.emit()
	check(tree.summary_label.text.contains("+90 Gold"), "Summary reflects capped fixed bonuses")
	await capture("capped_summary")
	game.get_node("InfoOverlay/Card/Catalog").scroll_vertical = 2000
	await capture("ability_bottom")
	game._on_info_close_pressed()
	var dispense: Control = preload("res://src/features/play/effects/drink_dispense_fx.gd").new()
	game.add_child(dispense)
	for i in range(3, 15):
		dispense.call(
			"begin", load(game.session.DRINK_DATA[i].asset), Color(game.session.DRINK_DATA[i].color)
		)
		check(
			dispense.art.texture != null,
			"Every drink has its own dispensing illustration"
		)
	dispense.queue_free()
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
			and game.session.drink_count(8) == 15
			and game.session.drink_count(3) == 11
			and game.session.water_count == 15
			and game.session.coin_bonus() == 90
			and game.session.parking_unlocked()
		),
		"New drink counts and spent balance survive reload"
	)
	for i in range(2, 15):
		check(game.session.drink_unlocked(i), "All branch unlocks survive reload")
	game.free()
	DirAccess.remove_absolute(path)
	print("Expanded skill checks: %d failures" % failures)
	quit(1 if failures else 0)


func _check_new_rules() -> void:
	check(FIXTURE.SESSION.DRINK_DATA[6].cost == 10, "Cola costs ten cans")
	check(FIXTURE.SESSION.DRINK_DATA[14].cost == 15, "Energy costs fifteen cans")
	for index in range(2, 15):
		var independent: RefCounted = FIXTURE.SESSION.new()
		var cost: int = independent.DRINK_DATA[index].cost
		independent.cans = cost - 1
		check(not independent.unlock(index), "Insufficient cans never unlock any drink")
		check(independent.cans == cost - 1, "Failed unlock preserves balance")
		independent.cans = cost
		check(independent.unlock(index), "Every drink unlocks independently, including golden")
		check(independent.cans == 0, "Exact cost is deducted once")
		check(independent.drinks == 0, "Unlock does not grant a drink or its ability")
		check(not independent.unlock(index), "Repeat unlock is rejected")
		check(independent.cans == 0, "Repeat unlock never charges again")
	var state: RefCounted = FIXTURE.SESSION.new()
	check(state.coin_weights() == [7000, 900, 500, 100, 1500], "Base search probabilities")
	state.ion_count = 1
	check(state.coin_weights() == [6900, 960, 530, 110, 1500], "Ion shifts 1 percentage point")
	state.extra_counts[4] = 1
	check(state.coin_weights() == [6700, 1080, 590, 130, 1500], "Apple shift stacks with ion")
	state.extra_counts[11] = 1
	check(state.coin_weights() == [6900, 1080, 590, 130, 1300], "Reduced miss moves to 1 Gold")
	state.ion_count = 0
	state.extra_counts.clear()
	for index in range(15):
		var cap: int = state.DRINK_DATA[index].max_enhancements
		for count in range(cap + 2):
			state._apply_drink(index)
			if count == cap - 2:
				check(state.enhancement_count(index) == cap - 1, "Strength below the cap still grows")
		check(state.drink_count(index) == cap + 2, "Collection is never truncated")
		check(state.enhancement_count(index) == cap, "Every drink obeys its ability cap")
	check(state.coin_bonus() == 90, "Only water, tea and barley contribute fixed Gold")
	check(state.coin_weights() == [6500, 1800, 950, 250, 500], "Max chance table sums to 100%")
	check(is_equal_approx(state.miss_chance(), 0.05), "Miss chance stops at five percent")
	check(is_equal_approx(state.double_reward_chance(), 0.2), "Ginger caps at twenty percent")
	check(is_equal_approx(state.double_click_chance(), 0.8), "Double clicks cap at eighty percent")
	check(state.clicks_required() == 8, "Only six vitamins reduce normal clicks to eight")
	state.start_search_fever()
	check(state.clicks_required() == 3, "Fever minus five stacks with vitamin minus two")
	check(state.search_fever_duration() == 20 and state.punch_fever_duration() == 15, "Time caps")
	check(state.calculate_reward(10) == 200, "Fixed Gold stacks with search fever only")
	check(state.parking_unlocked(), "Golden collection records unlock parking")

	var draw: RefCounted = FIXTURE.SESSION.new()
	check(draw.golden_chance() == 0, "Golden never appears before its can unlock")
	draw.cans = 500
	for index in [2, 9, 4, 10, 11, 8, 12, 5, 3, 13, 6, 14]:
		check(draw.unlock(index), "Existing unlock costs remain usable")
	check(not draw.drink_unlocked(7), "Golden still requires a separate unlock")
	var before_golden: int = draw.cans
	check(draw.unlock(7) and draw.cans == before_golden - 30, "Golden costs thirty cans")
	check(is_equal_approx(draw.golden_chance(), 0.001), "Unlocked golden starts at 0.1%")
	check(draw.DRINKS.draw_for_roll(draw, 0.000999) == 7, "Golden lower interval")
	check(draw.DRINKS.draw_for_roll(draw, 0.001) == 0, "Exact threshold starts normal pool")
	var normals: Array[int] = draw.purchasable_drinks()
	normals.erase(7)
	for slot in range(normals.size()):
		var roll: float = 0.001 + 0.999 * (slot + 0.5) / normals.size()
		check(draw.DRINKS.draw_for_roll(draw, roll) == normals[slot], "Normal weights are equal")
	draw.water_count = 10
	check(not draw.purchasable_drinks().has(0), "Capped water leaves the draw pool")
	normals.erase(0)
	for slot in range(normals.size()):
		var roll: float = 0.001 + 0.999 * (slot + 0.5) / normals.size()
		check(draw.DRINKS.draw_for_roll(draw, roll) == normals[slot], "Remaining weights rebalance")
	for level in [0, 1, 9, 10, 50]:
		draw.extra_counts[13] = level
		var expected: float = minf(0.1, 0.001 + mini(level, 10) * 0.01)
		check(is_equal_approx(draw.golden_chance(), expected), "Melon applies its capped rate")
	for index in range(15):
		if index == 7:
			continue
		while not draw.enhancement_complete(index):
			draw._apply_drink(index)
	draw.unlocked_drinks.erase(7)
	check(draw.golden_chance() == 0, "Even the completion guarantee cannot bypass golden unlock")
	check(draw.DRINKS.draw_for_roll(draw, 0.0) != 7, "Locked golden is never forced")
	draw.unlocked_drinks.append(7)
	check(draw.golden_chance() == 1.0, "All fourteen caps guarantee the next golden")
	check(draw.DRINKS.draw_for_roll(draw, 1.0) == 7, "Guarantee even includes the upper endpoint")
	draw._apply_drink(7)
	check(draw.golden_chance() == 0 and draw.purchasable_drinks() == [6, 14], "Only fever repeats")
	var before_cans: int = draw.cans
	draw._apply_drink(6)
	draw._apply_drink(14)
	check(draw.cans == before_cans + 2, "Repeated fever drinks each grant one can")
	check(
		draw.enhancement_count(6) == 1 and draw.enhancement_count(14) == 1,
		"Unlock strengths stay one"
	)

	var empty_pool: RefCounted = FIXTURE.SESSION.new()
	empty_pool.water_count = 10
	empty_pool.green_tea_count = 10
	empty_pool.money = 1000
	check(not empty_pool.purchase(), "No eligible drinks never starts a purchase")
	check(empty_pool.money == 1000 and empty_pool.purchase_count == 0, "No charge for empty pool")
	var outcome := OutcomeSession.new()
	outcome.water_count = 10
	outcome.green_tea_count = 10
	outcome.extra_counts = {3: 6, 9: 10, 10: 10}
	outcome.start_search_fever()
	outcome.start_punch_fever()
	outcome.doubled = true
	seed(2210)
	var base: int = outcome.SEARCH.coin_for_roll(outcome, randf())
	seed(2210)
	check(outcome.punch() == (base + 90) * 2 * 2 * 3, "Ginger, search and punch all stack")
	outcome.empty = true
	var before_money: int = outcome.money
	check(outcome.punch() == 0 and outcome.money == before_money, "Miss stays zero with all buffs")
	outcome.double_click = true
	outcome.search_fever_remaining = 0
	outcome.click_stack = 0
	check(outcome.search() == -1 and outcome.click_stack == 2, "Double click advances two only")
	outcome.money = 1000
	outcome.ion_unlocked = true
	outcome.unlocked_drinks.assign([6, 14])
	for drink in [6, 6, 14, 14]:
		outcome.forced_drink = drink
		check(outcome.purchase(), "Repeated fever drinks remain purchasable")
		outcome.finish_purchase(outcome.purchase_count)
		check(
			outcome.search_fever_remaining > 0 if drink == 6 else outcome.punch_fever_remaining > 0,
			"Repeated receipt triggers the matching fever"
		)
