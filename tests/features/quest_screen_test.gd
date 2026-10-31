extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")
const DESIGN = preload("res://src/shared/ui/design_view.gd")
const EFFECT = preload("res://src/features/quests/reward_fx.gd")

var failures: int = 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _initialize() -> void:
	run_checks.call_deferred()


func run_checks() -> void:
	root.content_scale_size = Vector2i.ZERO
	root.size = Vector2i(1152, 648)
	var game = FIXTURE.create_game(root)
	await process_frame
	var hud = game.get_node("QuestHud")
	var coin_row := DESIGN.shape(hud, "Quest / Coin")
	var can_row := DESIGN.shape(hud, "Quest / Can")
	check(not game.has_node("QuestToast"), "The central achievement card is removed")
	check(hud.current_id == "coin" and coin_row.is_visible_in_tree(),
		"The first unclaimed quest is displayed on entry")
	check(not can_row.is_visible_in_tree(), "Later quests are hidden")
	check(DESIGN.shape(coin_row, "Text / Count").text == "0/10",
		"The current quest displays its progress")
	game.session.facilities.alley.collected_cans = 5
	game.session.cans = 5
	game._refresh_ui()
	check(game.session.collected_cans() == 5, "Facility cans count once towards the quest")
	check(game.session.quest_status("can").ready and not can_row.is_visible_in_tree(),
		"Background accumulation does not reveal a later ready quest")
	check(hud.actions["can"].disabled, "A hidden quest has no active claim button")
	game._claim_quest("can")
	check(game.session.money == 0 and not game.session.can_quest_reward_claimed,
		"The Play claim boundary rejects a later quest even when it is ready")
	game._claim_quest("coin")
	check(game.session.money == 0, "An incomplete current quest cannot pay")
	game.session.quest_clicks = 10
	game._refresh_ui()
	game._process(21.0)
	check(hud.actions["coin"].is_visible_in_tree() and not game.has_node("QuestToast"),
		"A ready quest remains claimable without a timed achievement card")
	game._on_ability_button_pressed()
	game._claim_quest("coin")
	check(game.session.money == 0, "Information windows block quest claims")
	game._on_info_close_pressed()
	game.session.start_search_fever()
	var fever_before: float = game.session.search_fever_remaining
	game._process(1.0)
	check(game.session.search_fever_remaining < fever_before,
		"The current quest permits fever time to advance")
	var clicks_before: int = game.session.click_stack
	await tap(game.earn_button.get_global_rect().get_center())
	check(game.session.click_stack > clicks_before, "The current quest permits search input")
	await press_escape()
	check(game.pause_menu.overlay.visible, "Escape opens pause directly")
	await press_escape()
	await tap(hud.actions["coin"].get_global_rect().get_center())
	check(game.session.money == 5000 and game.session.quest_reward_claimed,
		"The first quest pays its reward exactly once")
	check(hud.current_id == "can" and can_row.is_visible_in_tree(),
		"Claiming advances immediately to the next quest")
	check(not coin_row.is_visible_in_tree() and can_row.position == Vector2.ZERO,
		"The next quest replaces the previous one in the same single row")
	check(not hud.actions["can"].disabled,
		"Previously accumulated progress is immediately claimable on its turn")
	hud.actions["coin"].pressed.emit()
	check(game.session.money == 5000, "A stale claim from the previous row cannot pay again")
	var restored = FIXTURE.SESSION.new()
	FIXTURE.store_for(game).load_into(restored)
	check(restored.money == 5000 and restored.quest_reward_claimed,
		"The reward and completion flag are saved together")
	var resumed = FIXTURE.create_game(root, restored)
	check(resumed.get_node("QuestHud").current_id == "can",
		"Reload resumes at the first unclaimed quest")
	var resume_path: String = FIXTURE.store_for(resumed).path
	resumed.free()
	DirAccess.remove_absolute(resume_path)
	await _check_reward_effect(game)
	var paid_before: int = game.session.money
	game._on_shop_button_pressed()
	check(game.session.money < paid_before, "The current quest permits purchases")
	await FIXTURE.wait_for_purchase_effects(game)
	var final_reward_balance: int = game.session.money + 100
	for resolution: Vector2i in [
		Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1440, 900),
	]:
		root.size = resolution
		await process_frame
		await process_frame
		for entry: Array in [
			[game.get_node("Navigation/AbilityButton"), "HUD / 능력 / normal"],
			[game.get_node("MenuButton"), "HUD / 메뉴 / normal"],
			[game.get_node("Design"), "UI / 버튼 / 시설"],
		]:
			var source: String = entry[1]
			var artwork := DESIGN.shape(entry[0], source)
			check(artwork.get_global_rect().size.is_equal_approx(
				DESIGN.shape(game.get_node("MenuButton"), "HUD / 메뉴 / normal").get_global_rect().size
			), "All HUD artwork scales together after resizing: " + source)
			var button: Button = artwork.get_parent() if artwork.get_parent() is Button else (
				artwork.get_node("Action")
			)
			check(button.get_global_rect().is_equal_approx(artwork.get_global_rect()),
				"The HUD artwork and input area keep the same bounds: " + source)
		var factor: float = minf(resolution.x / 1152.0, resolution.y / 648.0)
		var origin: Vector2 = (Vector2(resolution) - Vector2(1152, 648) * factor) * 0.5
		check(hud.get_global_rect().end.is_equal_approx(origin + Vector2(1136, 60) * factor),
			"The single row keeps the game area's upper-right margin")
		check(hud.scale.is_equal_approx(Vector2.ONE * factor),
			"The row's art, text and input scale uniformly")
	game.session.cans = 0
	game._refresh_ui()
	check(game.session.quest_status("can").progress == 5,
		"Spending cans does not reduce lifetime quest progress")
	await tap(hud.actions["can"].get_global_rect().get_center())
	check(game.session.money == final_reward_balance and game.session.can_quest_reward_claimed,
		"The second quest pays its own reward")
	check(not hud.visible and hud.current_id.is_empty(),
		"The HUD disappears when all quests have been claimed")
	game._claim_quest("can")
	check(game.session.money == final_reward_balance, "Completed quests cannot be claimed twice")
	FIXTURE.store_for(game).load_into(restored)
	check(not restored.claim_quest("can") and restored.money == final_reward_balance,
		"Reloading cannot repay a completed quest")
	var completed = FIXTURE.create_game(root, restored)
	check(not completed.get_node("QuestHud").visible,
		"Completed saves keep the quest HUD hidden on entry")
	var completed_path: String = FIXTURE.store_for(completed).path
	completed.free()
	DirAccess.remove_absolute(completed_path)
	var path: String = FIXTURE.store_for(game).path
	game.free()
	DirAccess.remove_absolute(path)
	var legacy = FIXTURE.SESSION.new()
	legacy.can_quest_reward_claimed = true
	legacy.quest_clicks = 10
	var legacy_game = FIXTURE.create_game(root, legacy)
	check(legacy_game.get_node("QuestHud").current_id == "coin",
		"Older independently claimed goals remain completed")
	legacy_game._claim_quest("coin")
	check(not legacy_game.get_node("QuestHud").visible and legacy.money == 5000,
		"Finishing an older save skips its already claimed second goal")
	var legacy_path: String = FIXTURE.store_for(legacy_game).path
	legacy_game.free()
	DirAccess.remove_absolute(legacy_path)
	print("Sequential quest HUD checks: %d failures" % failures)
	quit(1 if failures else 0)


func _check_reward_effect(game: Control) -> void:
	var effect: Control = game.get_children().filter(
		func(node: Node) -> bool: return node.get_script() == EFFECT
	)[0]
	effect.set_process(false)
	var clicks: int = game.session.click_stack
	await tap(game.earn_button.get_global_rect().get_center())
	check(game.session.click_stack > clicks, "The Gold animation permits search input")
	check(effect.particles.size() >= 24, "The reward produces a large burst of Gold")
	effect._process(1.3)
	check(effect.particles.all(func(p: Dictionary) -> bool: return p.node.position.y > 480),
		"The burst lands on the floor before being absorbed")
	effect._process(0.9)
	check(effect.particles.any(func(p: Dictionary) -> bool: return p.node.position.y < 400),
		"Floor coins move back towards the upper wallet")
	effect._process(0.4)
	var wallet: Vector2 = (
		effect.get_global_transform().affine_inverse()
		* game.money_label.get_global_rect().get_center()
	)
	check(effect.particles.all(func(p: Dictionary) -> bool:
		return (p.node.position + p.node.size * 0.5).distance_to(wallet) < 160
	), "Coins converge on the actual Gold HUD before disappearing")
	effect._process(0.2)
	await process_frame
	check(not is_instance_valid(effect), "Reward particles are removed after absorption")


func tap(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for down: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
		await process_frame


func press_escape() -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	root.push_input(event, true)
	await process_frame
	await process_frame
