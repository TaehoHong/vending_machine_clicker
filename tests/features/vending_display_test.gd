extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var game = FIXTURE.create_game(root)
	var path := "res://.godot/vending_display_test_%d.cfg" % Time.get_ticks_usec()
	FIXTURE.store_for(game).path = path
	FIXTURE.store_for(game).load_into(game.session)
	game._refresh_ui()
	assert(game.session.DRINK_DATA.size() == 15)
	assert(game.session.purchasable_drinks() == [0, 1])
	assert(FIXTURE.displayed_slots(game) == 3)
	game.session.water_count = 10
	game.session.green_tea_count = 10
	game._refresh_ui()
	assert(game.session.purchasable_drinks().is_empty())
	assert(FIXTURE.displayed_slots(game) == 3)
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(
			"res://.godot/test_artifacts/overlapping-purchase/base-drinks-at-cap.png"
		)
	game.session.water_count = 0
	game.session.green_tea_count = 0
	game.session.cans = 500
	game._on_skill_button_pressed()
	var tree = game.get_node("InfoOverlay/Card/SkillTree")
	var expected_slots: int = 3
	var reverse_order: Array = tree.ORDER.duplicate()
	reverse_order.reverse()
	for index in reverse_order:
		var previous: int = game.session.cans
		tree.get_unlock_button(index).pressed.emit()
		assert(game.session.drink_unlocked(index))
		assert(game.session.cans == previous - game.session.DRINK_DATA[index].cost)
		expected_slots |= 1 << int(game.session.DRINK_DATA[index].display_slot)
		assert(
			(
				FIXTURE.displayed_slots(game)
				== expected_slots
			)
		)
		assert(game.session.purchasable_drinks().has(index))
		game.session.last_drink = index
		game._update_result()
		assert(game.result_art.texture.resource_path == game.session.DRINK_DATA[index].asset)
	assert(expected_slots == 32767)
	game._on_info_close_pressed()
	game._on_ability_button_pressed()
	for data in game.session.DRINK_DATA:
		assert(game.get_node("InfoOverlay/Card/Catalog/Rows/" + data.key).visible)
	game._save_progress()
	game.free()
	game = FIXTURE.create_game(root)
	FIXTURE.store_for(game).path = path
	FIXTURE.store_for(game).load_into(game.session)
	game._refresh_ui()
	assert(game.session.purchasable_drinks().size() == 15)
	assert(FIXTURE.displayed_slots(game) == 32767)
	game.free()
	DirAccess.remove_absolute(path)
	print(
		"15-drink purchase pool, unlock gates, stock display, result art and save restoration checks passed."
	)
	quit()
