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
	var progress_hud := DESIGN.shape(game.get_node("QuestHud"), "Quest / Coin")
	check(progress_hud != null and progress_hud.is_visible_in_tree(),
		"Quest progress is permanently visible without opening a window")
	if progress_hud == null:
		game.free()
		quit(1)
		return
	var hud = game.get_node("QuestHud")
	var coin_row := DESIGN.shape(hud, "Quest / Coin")
	var can_row := DESIGN.shape(hud, "Quest / Can")
	check(DESIGN.shape(coin_row, "Text / Count").text == "0/10",
		"Coin progress is visible on entry")
	check(DESIGN.shape(can_row, "Text / Count").text == "0/5",
		"Can progress is visible on entry")
	game.session.facilities.alley.collected_cans = 3
	game.session.cans = 3
	check(game.session.collected_cans() == 3, "Facility cans count once towards the quest")
	game.session.facilities.alley.collected_cans = 0
	game.session.cans = 0
	game.session.drinks = 5
	game.session.water_count = 5
	game._refresh_ui()
	check(game.quest_toast.visible and game.quest_toast.current_id == "can",
		"The second goal announces completion before the first goal is claimed")
	check(game.session.money == 0, "Achievement alone does not pay a reward")
	game._claim_quest("coin")
	check(game.session.money == 0, "The session rejects an incomplete goal even outside its button")
	check(not hud.actions["can"].disabled, "The second goal is independently ready")
	check(hud.actions["coin"].disabled, "An incomplete goal cannot be claimed")
	await tap(hud.actions["can"].get_global_rect().get_center())
	check(game.session.money == 100 and game.session.can_quest_reward_claimed,
		"The permanent HUD pays exactly its own reward")
	check(not game.session.quest_reward_claimed and hud.is_visible_in_tree(),
		"Claiming preserves the other goal and the HUD")
	check(DESIGN.shape(can_row, "Label / Status").visible,
		"Claimed goals remain visible as completed")
	check(not game.quest_toast.visible, "A HUD claim immediately removes its achievement card")
	game._claim_quest("can")
	check(game.session.money == 100, "Repeated claims do not pay twice")
	var restored = FIXTURE.SESSION.new()
	FIXTURE.store_for(game).load_into(restored)
	check(restored.money == 100 and restored.can_quest_reward_claimed,
		"The payout and independent row flag are saved together")
	check(not restored.claim_quest("can"), "Reloading cannot pay an already claimed reward")
	check(restored.collected_cans() == 5, "Spent cans preserve lifetime progress after reload")
	var effect: Control = game.get_children().filter(
		func(node: Node) -> bool: return node.get_script() == EFFECT
	)[0]
	effect.set_process(false)
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
	game.session.start_search_fever()
	var fever_before: float = game.session.search_fever_remaining
	game._process(1.0)
	check(game.session.search_fever_remaining < fever_before,
		"The permanent HUD permits fever time to advance")
	var clicks_before: int = game.session.click_stack
	await tap(game.earn_button.get_global_rect().get_center())
	check(game.session.click_stack > clicks_before,
		"The permanent HUD permits background search")
	var paid_before: int = game.session.money
	game._on_shop_button_pressed()
	check(game.session.money < paid_before, "The permanent HUD permits purchases")
	await FIXTURE.wait_for_purchase_effects(game)
	await press_escape()
	check(game.pause_menu.overlay.visible,
		"Escape opens pause without an intermediate quest window")
	await press_escape()
	game.session.quest_clicks = 10
	game._refresh_ui()
	check(game.quest_toast.visible and game.quest_toast.current_id == "coin",
		"A newly achieved goal names the matching quest in the card")
	game.quest_toast.advance(19.9, false)
	check(game.quest_toast.visible, "The entire achievement card remains for nearly 20 seconds")
	game.quest_toast.advance(0.11, false)
	check(not game.quest_toast.visible and game.session.quest_status("coin").ready,
		"At 20 seconds only the card expires, never the unclaimed reward")
	game._refresh_ui()
	check(not game.quest_toast.visible, "Refreshing UI does not restart an expired card")
	check(not hud.actions["coin"].disabled,
		"Expired achievement cards leave rewards available in the permanent HUD")
	var money_before: int = game.session.money
	await tap(hud.actions["coin"].get_global_rect().get_center())
	check(game.session.money == money_before + 5000,
		"An expired card's reward remains claimable from the HUD")
	check(hud.actions["coin"].disabled and hud.actions["can"].disabled,
		"Both completed goals prevent repeat claims")
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
			),
				"All HUD artwork scales together after resizing: " + source)
			var button: Button = artwork.get_parent() if artwork.get_parent() is Button else (
				artwork.get_node("Action")
			)
			check(button.get_global_rect().is_equal_approx(artwork.get_global_rect()),
				"The HUD artwork and input area keep the same bounds: " + source)
		var factor: float = minf(resolution.x / 1152.0, resolution.y / 648.0)
		var origin: Vector2 = (Vector2(resolution) - Vector2(1152, 648) * factor) * 0.5
		check(hud.get_global_rect().end.is_equal_approx(origin + Vector2(1136, 108) * factor),
			"The permanent HUD keeps the game area's 16px upper-right margin")
		check(hud.scale.is_equal_approx(Vector2.ONE * factor),
			"Quest art, text and input scale uniformly after resizing")
	var path: String = FIXTURE.store_for(game).path
	game.free()
	DirAccess.remove_absolute(path)
	await _check_toast_claim()
	print("Quest HUD checks: %d failures" % failures)
	quit(1 if failures else 0)


func _check_toast_claim() -> void:
	root.size = Vector2i(1152, 648)
	var game = FIXTURE.create_game(root)
	game.session.quest_clicks = 10
	game._refresh_ui()
	await process_frame
	var remaining: float = game.quest_toast.remaining
	game._on_ability_button_pressed()
	game._process(2.0)
	check(not game.quest_toast.visible and game.quest_toast.remaining == remaining,
		"Information windows hide the card and preserve its display time")
	game._on_info_close_pressed()
	game._process(0)
	await tap(game.quest_toast.claim_button.get_global_rect().get_center())
	check(game.session.money == 5000 and not game.quest_toast.visible,
		"The card's own button pays once and hides it immediately")
	var clicks: int = game.session.click_stack
	await tap(game.earn_button.get_global_rect().get_center())
	check(game.session.click_stack > clicks,
		"The Gold animation permits search input while it plays")
	var path: String = FIXTURE.store_for(game).path
	game.free()
	DirAccess.remove_absolute(path)


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
