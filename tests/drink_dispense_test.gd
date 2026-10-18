extends SceneTree

class PreviewGame extends "res://game.gd":
	func _load_progress() -> void: pass
	func _save_progress() -> void: pass
	func _roll_drink() -> int: return 6

func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
	var game = load("res://Game.tscn").instantiate()
	game.set_script(PreviewGame)
	root.add_child(game)
	game.money = 300
	game._on_shop_button_pressed()
	game._on_shop_button_pressed()
	assert(game.money == 200 and game.drinks == 1 and game.cans == 1)
	assert(game.inserting_coin and not game.result_overlay.visible)
	game.coin_tween.pause()
	game.coin_tween.custom_step(1.04)
	assert(not game.coin_token.visible and game.drink_dispense_fx.visible)
	assert(game.drink_dispense_fx.art.texture.resource_path == game.DRINK_DATA[6].asset)
	game.coin_tween.custom_step(0.3)
	assert(game.drink_dispense_fx.center.distance_to(game.drink_dispense_fx.outlet) < 40)
	assert(absf(game.drink_dispense_fx.art.rotation - PI * 0.5) < 0.07, "Drink must leave the outlet lying sideways")
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
	assert(game.inserting_coin and not game.result_overlay.visible)
	game.pause_menu.set_open(false)
	game.coin_tween.play()
	await game.coin_tween.finished
	assert(not game.inserting_coin and not game.result_overlay.visible)
	assert(not game.drink_dispense_fx.visible and game.ability_toast.visible)
	assert(game.ability_toast.title.text.contains("콜라"))
	assert(game.ability_toast.effect.text == game.DRINK_DATA[6].effect)
	game.ability_toast.animation.pause()
	game.ability_toast.animation.custom_step(0.95)
	assert(is_equal_approx(game.ability_toast.modulate.a, 1.0), "Toast must remain opaque for one second")
	game.ability_toast.animation.custom_step(0.35)
	assert(game.ability_toast.modulate.a > 0 and game.ability_toast.modulate.a < 1)
	game.ability_toast.animation.custom_step(0.4)
	assert(not game.ability_toast.visible)
	assert(game.search_fever_remaining == 10 and not game.search_fever_pending)
	assert(not game.shop_button.disabled)
	game.free()
	print("Sideways dispensing, ability button arrival, timed toast, duplicate prevention, resize, pause and automatic fever checks passed.")
	quit()
