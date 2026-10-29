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
	var hud := DESIGN.shape(game, "Action / Open Quests")
	check(hud != null, "Memo HUD opens the quest list instead of a permanent goal panel")
	game.session.facilities.alley.collected_cans = 3
	game.session.cans = 3
	check(game.session.collected_cans() == 3, "Facility cans count once towards the quest")
	if hud == null:
		game.free()
		print("Quest screen checks: %d failures" % failures)
		quit(1)
		return
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
	await tap(game.quest_button.get_global_rect().get_center())
	check(is_instance_valid(game.quest_screen), "Clicking the memo opens the list")
	if not is_instance_valid(game.quest_screen):
		quit(1)
		return
	check(not game.quest_screen.actions["can"].disabled, "The second row is independently ready")
	check(game.quest_screen.actions["coin"].disabled, "An incomplete goal cannot be claimed")
	await tap(game.quest_screen.actions["can"].get_global_rect().get_center())
	check(game.session.money == 100 and game.session.can_quest_reward_claimed,
		"The second row pays exactly its own reward")
	check(not game.session.quest_reward_claimed and is_instance_valid(game.quest_screen),
		"Claiming keeps the list open and leaves the other goal untouched")
	check(not game.quest_toast.visible, "A list claim immediately removes its achievement card")
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
	var clicks_before: int = game.session.click_stack
	game._process(1.0)
	game._on_earn_button_pressed()
	game._on_shop_button_pressed()
	check(game.session.search_fever_remaining == fever_before,
		"The quest list pauses fever time")
	check(game.session.click_stack == clicks_before and game.session.money == 100,
		"The quest list blocks background search and purchases")
	await press_escape()
	check(not is_instance_valid(game.quest_screen) and not paused,
		"Escape closes the list before opening pause")
	check(game.quest_button.has_focus(), "Closing the list returns focus to the memo")
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
	check(DESIGN.shape(hud, "Badge / Claimable").visible, "The memo keeps unclaimed rewards visible")
	await tap(game.quest_button.get_global_rect().get_center())
	await tap(game.quest_screen.actions["coin"].get_global_rect().get_center())
	check(game.session.money == 5100, "An expired card's reward remains claimable in the list")
	check(not DESIGN.shape(hud, "Badge / Claimable").visible,
		"The notification dot clears when all rewards have been claimed")
	await tap(DESIGN.shape(game.quest_screen.canvas, "Action / Close").get_global_rect().get_center())
	check(not is_instance_valid(game.quest_screen), "The original X button closes the list")
	for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(1600, 900)]:
		root.size = resolution
		await process_frame
		await process_frame
		check(hud.get_global_rect().end.x < resolution.x,
			"The uniformly scaled memo stays inside the resized viewport")
		game.quest_button.pressed.emit()
		var rect: Rect2 = game.quest_screen.canvas.get_global_rect()
		check(rect.get_center().is_equal_approx(Vector2(resolution) * 0.5),
			"The quest list remains centered after resizing")
		game.quest_screen.close()
		await process_frame
	var path: String = FIXTURE.store_for(game).path
	game.free()
	DirAccess.remove_absolute(path)
	await _check_toast_claim()
	print("Quest screen checks: %d failures" % failures)
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
