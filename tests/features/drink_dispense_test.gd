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
	var folder: String = "res://.godot/test_artifacts/overlapping-purchase"
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(name + ".png"))


func run_checks() -> void:
	var game = FIXTURE.create_game(root, PreviewGame.new())
	game.session.money = 307
	game._on_shop_button_pressed()
	var first: Dictionary = game._purchase_effects[1]
	first.animation.pause()
	first.animation.custom_step(0.1)
	game._on_shop_button_pressed()
	var second: Dictionary = game._purchase_effects[2]
	second.animation.pause()
	assert(first.coin.visible and second.coin.visible)
	assert(first.coin != second.coin, "Each click immediately creates its own coin")
	assert(first.coin.coin_position != second.coin.coin_position)
	first.animation.custom_step(0.15)
	second.animation.custom_step(0.15)
	assert(first.coin.opacity > 0 and second.coin.opacity > 0)
	await capture("overlapping-coins")
	game._on_shop_button_pressed()
	var third: Dictionary = game._purchase_effects[3]
	third.animation.pause()
	assert(game.session.money == 0 and game.session.drinks == 3 and game.session.cans == 3)
	assert(game.session.pending_purchases == {1: 6, 2: 14, 3: 0})
	assert(game.session.current_draw_price() == 107)
	game._on_shop_button_pressed()
	assert(game._purchase_effects.size() == 3, "Insufficient funds creates no effect")
	game.ability_toast.animation.pause()
	game._on_earn_button_pressed()
	assert(game.session.click_stack == 1, "Search works during overlapping purchases")
	game._on_ability_button_pressed()
	assert(game.info_overlay.visible)
	for entry: Dictionary in game._purchase_effects.values():
		assert(entry.coin.get_index() < game.info_overlay.get_index())
		assert(entry.drink.get_index() < game.info_overlay.get_index())
	game._on_earn_button_pressed()
	assert(game.session.click_stack == 1, "The modal still blocks background search")
	await capture("ability-during-purchase")
	game._on_info_close_pressed()
	game._save_progress()
	var restored: RefCounted = FIXTURE.SESSION.new()
	FIXTURE.store_for(game).load_into(restored)
	assert(restored.drinks == 3 and restored.cans == 3 and restored.money == 0)
	assert(restored.pending_purchases.is_empty() and restored.current_draw_price() == 107)
	first.animation.custom_step(1.1)
	second.animation.custom_step(1.1)
	assert(first.drink.visible and second.drink.visible)
	assert(game.session.pending_purchases.size() == 3, "Both drinks precede first completion")
	assert(first.drink.art.texture.resource_path == game.session.DRINK_DATA[6].asset)
	assert(second.drink.art.texture.resource_path == game.session.DRINK_DATA[14].asset)
	assert(absf(first.drink.art.rotation - PI * 0.5) < 0.07)
	await capture("overlapping-drinks")
	var before: Vector2 = first.drink.destination
	game.set_anchors_preset(Control.PRESET_TOP_LEFT)
	game.size = Vector2(1280, 720)
	await process_frame
	game._position_coin_slot()
	assert(first.drink.destination != before)
	for entry: Dictionary in game._purchase_effects.values():
		assert(entry.drink.destination == game.ability_receipt_position())
	first.animation.play()
	second.animation.play()
	game.pause_menu.set_open(true)
	var elapsed: float = first.coin.elapsed
	var center: Vector2 = first.drink.center
	await create_timer(0.1).timeout
	assert(first.coin.elapsed == elapsed and first.drink.center == center)
	game.pause_menu.set_open(false)
	first.animation.pause()
	second.animation.pause()
	first.animation.custom_step(2.0)
	assert(not game.session.pending_purchases.has(1))
	assert(game.session.search_fever_remaining == 10 and game.session.punch_fever_remaining == 0)
	assert(not game.session.finish_purchase(1), "Duplicate completion cannot trigger fever")
	assert(game.ability_toast.title.text == "골드 부족", "Earlier feedback keeps its order")
	game.ability_toast.animation.pause()
	second.animation.custom_step(2.0)
	assert(game.session.punch_fever_remaining == 5)
	assert(game.ability_toast.title.text == "골드 부족", "New arrivals do not overwrite a toast")
	game._on_shop_button_pressed()
	assert(game.session.drinks == 3, "Punch fever keeps cabinet clicks as punches")
	third.animation.custom_step(3.0)
	assert(game._purchase_effects.is_empty() and not game.session.inserting_coin)
	game.ability_toast.animation.custom_step(0.95)
	assert(is_equal_approx(game.ability_toast.modulate.a, 1.0))
	game.ability_toast.animation.custom_step(0.35)
	assert(game.ability_toast.modulate.a > 0 and game.ability_toast.modulate.a < 1)
	game.ability_toast.animation.custom_step(0.4)
	assert(game.ability_toast.title.text.contains("콜라"))
	game.ability_toast.animation.pause()
	game.ability_toast.animation.custom_step(1.7)
	assert(game.ability_toast.title.text.contains("에너지"))
	game.ability_toast.animation.pause()
	game.ability_toast.animation.custom_step(1.7)
	assert(game.ability_toast.title.text.contains("물"))
	game.ability_toast.animation.pause()
	game.ability_toast.animation.custom_step(1.7)
	assert(not game.ability_toast.visible)
	assert(not game.session.finish_purchase(3))
	# Completion identity must also work out of order and for duplicate drink results.
	var session: RefCounted = FIXTURE.SESSION.new()
	session.pending_purchases = {1: 6, 2: 14, 3: 6}
	assert(session.finish_purchase(2) and session.punch_fever_remaining == 5)
	assert(session.search_fever_remaining == 0 and session.pending_purchases.size() == 2)
	assert(session.finish_purchase(3) and session.search_fever_remaining == 10)
	assert(session.pending_purchases == {1: 6} and not session.finish_purchase(3))
	game.free()
	print("Overlapping coins/drinks, independent results, input, saves, toast, pause/resize passed.")
	quit()
