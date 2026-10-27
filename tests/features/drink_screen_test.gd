extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")


func _initialize() -> void:
	call_deferred("run_checks")
	create_timer(25).timeout.connect(func() -> void: quit(1))


func hover(control: Control) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = control.get_global_rect().get_center()
	root.push_input(motion, true)
	await process_frame
	await process_frame


func tap(control: Control) -> void:
	await hover(control)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = control.get_global_rect().get_center()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
		await process_frame


func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var folder: String = "res://.godot/test_artifacts/drink_screen_test"
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join("%s.png" % name))


func run_checks() -> void:
	root.size = Vector2i(1152, 648)
	var game = FIXTURE.create_game(root)
	game.session.cans = 18
	game.session.water_count = 6
	assert(not game.has_node("Navigation/SkillButton"))
	game._refresh_ui()
	await capture("play")
	await tap(game.get_node("Navigation/AbilityButton"))
	await process_frame
	await process_frame
	var screen = game.get_node("InfoOverlay/Card/SkillTree")
	assert(screen.products.size() == 15)
	assert(screen.summary_button.get_theme_stylebox("normal") is StyleBoxTexture)
	assert(screen.close_button.get_theme_stylebox("normal") is StyleBoxTexture)
	assert(screen.canvas.size == Vector2(1152, 648))
	assert(screen.products.size() == 15)
	assert(not screen.detail_panel.visible and screen.selected_index == -1)
	assert(screen.find_children("*", "Line2D", true, false).is_empty())
	await capture("initial")
	await hover(screen.products[2])
	assert(
		not screen.detail_panel.visible and screen.selected_index == -1,
		"Hover must not open the card"
	)
	await tap(screen.products[6])
	assert(screen.detail_panel.visible and not screen.buttons[6].disabled)
	var art: TextureRect = screen.detail_panel.get_node_or_null("DrinkArt")
	assert(art != null, "Selected drink must appear in the detail header")
	assert(art.texture == load(screen.DATA[6].asset))
	assert(screen.detail_status.text == "해금 후 자판기에서 등장")
	assert(screen.unlock_labels[6].text == "10개로 해금")
	await tap(screen.products[5])
	assert(not screen.buttons[5].disabled and screen.unlock_labels[5].text == "15개로 해금")
	assert(not game.session.drink_unlocked(8), "Orange is available before lime unlock")
	assert(not screen.detail_status.text.contains("먼저"))
	await capture("independent-orange")
	await tap(screen.products[2])
	assert(screen.selected_index == 2 and screen.detail_panel.visible)
	assert(not screen.buttons[2].disabled and screen.buttons[2].visible)
	assert(game.session.cans == 18, "Selecting must not spend cans")
	await capture("locked-selected")
	await hover(screen.products[0])
	assert(screen.selected_index == 2, "Moving over another drink must not change selection")
	await tap(screen.buttons[2])
	assert(game.session.ion_unlocked and game.session.cans == 13 and game.session.drinks == 0)
	assert(not screen.buttons[2].is_visible_in_tree(), "Unlocked drinks have no purchase button")
	game._on_unlock_drink_requested(2)
	assert(game.session.cans == 13, "Repeated unlock must not charge twice")
	await tap(screen.products[0])
	assert(art.texture == load(screen.DATA[0].asset))
	assert(screen.detail_count.text.contains("6") and screen.detail_status.text.contains("+6 Gold"))
	await capture("acquired-selected")
	await tap(screen.summary_button)
	assert(screen.summary_panel.visible and not screen.detail_panel.visible)
	assert(not screen.summary_label.text.is_empty())
	await capture("summary")
	await tap(screen.summary_button)
	assert(not screen.summary_panel.visible)
	game._on_info_close_pressed()
	game._on_ability_button_pressed()
	assert(screen.visible and not screen.detail_panel.visible and screen.selected_index == -1)
	await hover(screen.products[2])
	assert(not screen.detail_panel.visible, "Reopening resets prior selection")
	root.size = Vector2i(800, 600)
	await process_frame
	await process_frame
	await tap(screen.products[14])
	# canvas_items uses virtual coordinates; the OS window can be smaller.
	var bounds := Rect2(Vector2.ZERO, game.size)
	assert(bounds.encloses(screen.detail_panel.get_global_rect()), "Card fits after resize")
	for product in screen.products.values():
		assert(bounds.encloses(product.get_global_rect()), "Every drink remains clickable")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	root.push_input(escape)
	assert(not game.info_overlay.visible)
	game.free()
	print(
		"Drink screen: click-only cards, silent hover, fresh open, independent unlocks, "
		+ "atomic can charge, acquired effects, summary, ESC and resize passed."
	)
	quit()
