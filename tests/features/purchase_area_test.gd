extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")


func _initialize() -> void:
	call_deferred("run_checks")


func tap(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	root.push_input(motion, true)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = position
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
		await process_frame


func run_checks() -> void:
	var game = FIXTURE.create_game(root)
	game.session.money = 1000
	game._refresh_ui()
	await process_frame
	var design: Control = game.get_node("Design")
	for point in [Vector2(480, 130), Vector2(560, 240), Vector2(685, 350)]:
		var before: int = game.session.drinks
		await tap(design.get_global_transform() * point)
		assert(game.session.inserting_coin and game.session.drinks == before + 1)
		assert(game._purchase_effects.values()[0].coin.get_child_count() == 0)
		await FIXTURE.wait_for_purchase_effects(game)
		assert(not game.result_overlay.visible and not game.session.inserting_coin)
	var before: int = game.session.drinks
	await tap(design.get_global_transform() * Vector2(570, 410))
	assert(
		game.session.drinks == before and not game.session.inserting_coin,
		"The dispensing tray must not purchase"
	)
	assert(not game.shop_button.get_global_rect().intersects(game.earn_button.get_global_rect()))
	game.free()
	print("Upper cabinet click coverage, tray exclusion and unnumbered coin checks passed.")
	quit()
