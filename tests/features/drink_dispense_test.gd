extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")


class PreviewGame:
	extends "res://src/game/game_session.gd"

	var next_result: int = 0
	var empty: bool = true

	func _roll_drink() -> int:
		var sequence: Array[int] = [6, 14, 0]
		var selected: int = sequence[next_result]
		next_result += 1
		return selected

	func _search_is_empty() -> bool:
		return empty


func _initialize() -> void:
	call_deferred("run_checks")


func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var folder: String = "res://.godot/test_artifacts/nonblocking-purchase"
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(name + ".png"))


func run_checks() -> void:
	var concurrent := PreviewGame.new()
	concurrent.money = 100
	assert(concurrent.purchase())
	concurrent.empty = false
	var earned: int = -1
	for click in range(10):
		earned = concurrent.search()
	assert(earned > 0 and concurrent.money == earned, "Search succeeds with a queued purchase")
	concurrent.start_punch_fever()
	assert(concurrent.punch() > 0, "Punch rewards also work while a purchase is queued")
	var game = FIXTURE.create_game(root, PreviewGame.new())
	game.session.money = 307
	game._on_shop_button_pressed()
	game._on_shop_button_pressed()
	game._on_shop_button_pressed()
	assert(game.session.money == 0 and game.session.drinks == 3 and game.session.cans == 3)
	assert(game.session.pending_purchases == [6, 14, 0])
	assert(game.session.current_draw_price() == 107)
	assert(game.session.search_fever_pending and game.session.punch_fever_pending)
	game._on_shop_button_pressed()
	assert(game.session.drinks == 3, "Insufficient funds never enqueue another drink")
	assert(not game.shop_button.disabled and not game.earn_button.disabled)
	assert(not game.get_node("Navigation/AbilityButton").disabled)
	game._on_earn_button_pressed()
	assert(game.session.click_stack == 1, "Search remains active during insertion")
	game._on_ability_button_pressed()
	assert(game.info_overlay.visible, "Ability screen opens during insertion")
	assert(game.coin_token.get_index() < game.info_overlay.get_index())
	assert(game.coin_token.z_index <= game.info_overlay.z_index)
	assert(game.drink_dispense_fx.get_index() < game.info_overlay.get_index())
	game._on_earn_button_pressed()
	assert(game.session.click_stack == 1, "The ability modal still blocks background search")
	await capture("ability-during-purchase")
	game._on_info_close_pressed()
	for click in range(9):
		game._on_earn_button_pressed()
	assert(game.session.click_stack == 0 and game.session.money == 0, "Miss gives no Gold")
	game._save_progress()
	var restored: RefCounted = FIXTURE.SESSION.new()
	FIXTURE.store_for(game).load_into(restored)
	assert(restored.money == 0 and restored.drinks == 3 and restored.purchase_count == 3)
	assert(restored.cans == 3 and restored.pending_purchases.is_empty())
	assert(restored.current_draw_price() == 107, "Reload never recharges or regrants queued results")
	assert(game.session.inserting_coin and not game.result_overlay.visible)
	game.coin_tween.pause()
	game.coin_tween.custom_step(1.04)
	assert(not game.coin_token.visible and game.drink_dispense_fx.visible)
	assert(game.drink_dispense_fx.art.texture.resource_path == game.session.DRINK_DATA[6].asset)
	await capture("queued-cola")
	game.coin_tween.custom_step(0.3)
	assert(game.drink_dispense_fx.center.distance_to(game.drink_dispense_fx.outlet) < 40)
	assert(
		absf(game.drink_dispense_fx.art.rotation - PI * 0.5) < 0.07,
		"Drink must leave the outlet lying sideways"
	)
	assert(not game.has_node("DrinkBox"))
	var before: Vector2 = game.drink_dispense_fx.destination
	game.set_anchors_preset(Control.PRESET_TOP_LEFT)
	game.size = Vector2(1280, 720)
	await process_frame
	game._position_coin_slot()
	assert(game.drink_dispense_fx.destination != before)
	assert(game.drink_dispense_fx.destination == game.ability_receipt_position())
	game.pause_menu.set_open(true)
	await create_timer(0.05).timeout
	assert(game.session.inserting_coin and not game.result_overlay.visible)
	game.pause_menu.set_open(false)
	game.coin_tween.play()
	await game.coin_tween.finished
	assert(game.session.pending_purchases == [14, 0] and not game.result_overlay.visible)
	assert(game.session.search_fever_remaining == 10 and game.session.punch_fever_remaining == 0)
	game._process(0.25)
	assert(game.session.search_fever_remaining < 10, "Next insertion never freezes fever")
	assert(not game.drink_dispense_fx.visible and game.ability_toast.visible)
	assert(game.ability_toast.title.text.contains("콜라"))
	assert(game.ability_toast.effect.text == game.session.DRINK_DATA[6].effect)
	game.ability_toast.animation.pause()
	game.ability_toast.animation.custom_step(0.95)
	assert(
		is_equal_approx(game.ability_toast.modulate.a, 1.0),
		"Toast must remain opaque for one second"
	)
	game.ability_toast.animation.custom_step(0.35)
	assert(game.ability_toast.modulate.a > 0 and game.ability_toast.modulate.a < 1)
	game.ability_toast.animation.custom_step(0.4)
	assert(not game.ability_toast.visible)
	assert(not game.session.search_fever_pending and game.session.punch_fever_pending)
	game.coin_tween.pause()
	game.coin_tween.custom_step(1.04)
	assert(game.drink_dispense_fx.art.texture.resource_path == game.session.DRINK_DATA[14].asset)
	game.coin_tween.play()
	await game.coin_tween.finished
	assert(game.session.pending_purchases == [0] and game.session.punch_fever_remaining == 5)
	assert(game.ability_toast.title.text.contains("에너지"))
	game._on_shop_button_pressed()
	assert(game.session.drinks == 3, "Punch fever keeps cabinet clicks as punches")
	assert(game.session.money == 0, "Punch misses also remain zero during another insertion")
	game.coin_tween.pause()
	game.coin_tween.custom_step(1.04)
	assert(game.drink_dispense_fx.art.texture.resource_path == game.session.DRINK_DATA[0].asset)
	game.coin_tween.play()
	await game.coin_tween.finished
	assert(not game.session.inserting_coin and not game.drink_dispense_fx.visible)
	assert(game.ability_toast.title.text.contains("물"))
	assert(not game.session.punch_fever_pending)
	assert(game.session.drinks == 3 and game.session.cans == 3 and game.session.money == 0)
	game.session.finish_purchase()
	assert(game.session.drinks == 3, "Completing an empty queue never grants anything")
	assert(not game.shop_button.disabled)
	game.free()
	print(
		"Queued draws, independent input, per-result art/toasts/fevers, "
		+ "atomic saves, sideways dispensing, resize and pause checks passed."
	)
	quit()
