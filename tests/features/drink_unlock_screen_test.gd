extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")


func _initialize() -> void:
	call_deferred("run_checks")
	create_timer(15).timeout.connect(func() -> void: quit(1))


func tap(control: Control) -> void:
	var point := control.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
		await process_frame


func run_checks() -> void:
	var game = FIXTURE.create_game(root)
	game.session.cans = 8
	game._on_skill_button_pressed()
	await process_frame
	var tree = game.get_node("InfoOverlay/Card/SkillTree")
	assert(tree.products.size() == 15)
	assert(is_equal_approx(
		preload("res://src/shared/ui/design_view.gd").shape(
			tree.canvas, "InfoOverlay / Card / SkillTree / Dim"
		).get_theme_stylebox("panel").bg_color.a, 89.0 / 255.0
	))
	assert(not tree.detail_panel.visible)
	assert(not game.get_node("InfoOverlay/Card/Title").visible)
	await tap(tree.products[6])
	assert(tree.selected_index == 6 and tree.buttons[6].disabled)
	assert(tree.detail_status.text == "해금 후 자판기에서 등장")
	assert(tree.unlock_labels[6].text == "10개로 해금", "Cola is blocked only by insufficient cans")
	await tap(tree.products[2])
	assert(tree.selected_index == 2 and not tree.buttons[2].disabled)
	await tap(tree.buttons[2])
	assert(game.session.ion_unlocked and game.session.cans == 3 and game.session.drinks == 0)
	assert(tree.buttons[2].disabled and not tree.buttons[2].is_visible_in_tree())
	assert(
		(
			(
				FIXTURE.displayed_slots(game)
				& (1 << 3)
			)
			!= 0
		)
	)
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	root.push_input(escape)
	assert(not game.info_overlay.visible and not paused)
	game._on_ability_button_pressed()
	assert(not game.get_node("InfoOverlay/Card/Title").visible)
	assert(game.get_node("InfoOverlay/Card").size == game.size)
	assert(not tree.detail_panel.visible)
	game._on_info_close_pressed()
	game._on_skill_button_pressed()
	root.size = Vector2i(1280, 720)
	await process_frame
	await process_frame
	var screen := Rect2(Vector2.ZERO, Vector2(root.size))
	for product in tree.products.values():
		assert(
			screen.encloses(product.get_global_rect()),
			"All products must remain visible after resize"
		)
	await tap(tree.close_button)
	assert(not game.info_overlay.visible)
	game.free()
	print(
		"Full-screen machine selection, lock states, can cost, display unlock, ESC, ability layout and resize passed."
	)
	quit()
