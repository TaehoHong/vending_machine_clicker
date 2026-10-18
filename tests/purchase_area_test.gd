extends SceneTree

class PreviewGame extends "res://game.gd":
	func _load_progress() -> void: pass
	func _save_progress() -> void: pass

func _initialize() -> void:
	call_deferred("run_checks")

func tap(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	root.push_input(motion)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = position
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event)
		await process_frame

func run_checks() -> void:
	var game = load("res://Game.tscn").instantiate()
	game.set_script(PreviewGame)
	root.add_child(game)
	game.money = 1000
	game._refresh_ui()
	await process_frame
	var machine: TextureRect = game.get_node("VendingMachine")
	var factor: float = machine.size.x / 1024.0
	for point in [Vector2(160, 160), Vector2(600, 450), Vector2(850, 1000)]:
		var before: int = game.drinks
		await tap(machine.position + point * factor)
		assert(game.inserting_coin and game.drinks == before + 1)
		assert(not game.coin_token.get_node("Symbol").visible)
		assert(game.coin_insert_fx.get_child_count() == 0)
		await game.coin_tween.finished
		assert(game.result_overlay.visible)
		game._on_result_close_pressed()
	var before: int = game.drinks
	await tap(machine.position + Vector2(500, 1200) * factor)
	assert(game.drinks == before and not game.inserting_coin, "The dispensing tray must not purchase")
	assert(not game.shop_button.get_global_rect().intersects(game.earn_button.get_global_rect()))
	game.free()
	print("Upper cabinet click coverage, tray exclusion and unnumbered coin checks passed.")
	quit()
