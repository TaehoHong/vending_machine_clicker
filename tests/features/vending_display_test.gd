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
	assert(game.get_node("VendingMachine").material.get_shader_parameter("unlocked_slots") == 3)
	game.session.cans = 500
	game._on_skill_button_pressed()
	var tree = game.get_node("InfoOverlay/Card/SkillTree")
	game._on_unlock_drink_requested(7)
	assert(not game.session.drink_unlocked(7), "Locked prerequisite must block the golden drink")
	var expected_slots: int = 3
	for index in tree.ORDER:
		var previous: int = game.session.cans
		tree.get_unlock_button(index).pressed.emit()
		assert(game.session.drink_unlocked(index))
		assert(game.session.cans == previous - game.session.DRINK_DATA[index].cost)
		expected_slots |= 1 << int(game.session.DRINK_DATA[index].display_slot)
		assert(
			(
				game.get_node("VendingMachine").material.get_shader_parameter("unlocked_slots")
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
	assert(game.get_node("VendingMachine").material.get_shader_parameter("unlocked_slots") == 32767)
	game.free()
	DirAccess.remove_absolute(path)
	print(
		"15-drink purchase pool, unlock gates, stock display, result art and save restoration checks passed."
	)
	quit()
