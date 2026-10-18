extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game = load("res://Game.tscn").instantiate()
	var path := "res://.godot/vending_display_test_%d.cfg" % Time.get_ticks_usec()
	game.save_path = path
	root.add_child(game)
	assert(game.DRINK_DATA.size() == 15)
	assert(game.purchasable_drinks() == [0, 1])
	assert(game.get_node("VendingMachine").material.get_shader_parameter("unlocked_slots") == 3)
	game.cans = 500
	game._on_skill_button_pressed()
	var tree = game.get_node("InfoOverlay/Card/SkillTree")
	game._on_unlock_drink_requested(7)
	assert(not game.drink_unlocked(7), "Locked prerequisite must block the golden drink")
	var expected_slots: int = 3
	for index in tree.ORDER:
		var previous: int = game.cans
		tree.get_unlock_button(index).pressed.emit()
		assert(game.drink_unlocked(index))
		assert(game.cans == previous - game.DRINK_DATA[index].cost)
		expected_slots |= 1 << int(game.DRINK_DATA[index].display_slot)
		assert(game.get_node("VendingMachine").material.get_shader_parameter("unlocked_slots") == expected_slots)
		assert(game.purchasable_drinks().has(index))
		game.last_drink = index
		game._update_result()
		assert(game.result_art.texture.resource_path == game.DRINK_DATA[index].asset)
	assert(expected_slots == 32767)
	game._on_info_close_pressed()
	game._on_ability_button_pressed()
	for data in game.DRINK_DATA:
		assert(game.get_node("InfoOverlay/Card/Catalog/Rows/" + data.key).visible)
	game._save_progress()
	game.free()
	game = load("res://Game.tscn").instantiate()
	game.save_path = path
	root.add_child(game)
	assert(game.purchasable_drinks().size() == 15)
	assert(game.get_node("VendingMachine").material.get_shader_parameter("unlocked_slots") == 32767)
	game.free()
	DirAccess.remove_absolute(path)
	print("15-drink purchase pool, unlock gates, stock display, result art and save restoration checks passed.")
	quit()
