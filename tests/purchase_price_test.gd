extends SceneTree
class PriceGame extends "res://game.gd":
	func _load_progress() -> void: pass
	func _roll_drink() -> int: return 0
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var game = load("res://Game.tscn").instantiate()
	game.set_script(PriceGame)
	game.save_path = "res://.godot/price-test.cfg"
	root.add_child(game)
	assert(game.current_draw_price() == 100)
	game.money = 1000
	game._on_shop_button_pressed()
	assert(game.money == 900 and game.purchase_count == 1 and game.current_draw_price() == 105)
	game._on_shop_button_pressed()
	assert(game.purchase_count == 1)
	var saved := ConfigFile.new()
	assert(saved.load(game.save_path) == OK and saved.get_value("progress","purchase_count") == 1)
	await game.coin_tween.finished
	game._on_shop_button_pressed()
	assert(game.money == 795 and game.purchase_count == 2 and game.current_draw_price() == 111)
	await game.coin_tween.finished
	game.money = 110
	game._on_shop_button_pressed()
	assert(game.money == 110 and game.purchase_count == 2 and not game.inserting_coin)
	game.money = 111
	game._on_shop_button_pressed()
	assert(game.money == 0 and game.purchase_count == 3 and game.current_draw_price() == 116)
	await game.coin_tween.finished
	game._save_progress()
	var loaded = load("res://Game.tscn").instantiate()
	loaded.save_path = game.save_path
	root.add_child(loaded)
	assert(loaded.purchase_count == 3 and loaded.current_draw_price() == 116)
	var legacy := ConfigFile.new()
	legacy.set_value("progress","drinks",6)
	legacy.save(game.save_path)
	loaded._load_progress()
	assert(loaded.purchase_count == 6 and loaded.current_draw_price() == 135)
	loaded.purchase_count = 99
	assert(loaded.current_draw_price() == 12524)
	loaded._refresh_ui()
	assert(loaded.get_node("SlotHint/Price").text == "12.5KG")
	loaded.free()
	game.free()
	DirAccess.remove_absolute("res://.godot/price-test.cfg")
	print("5 percent compounding, atomic purchase/save, duplicate and insufficient funds, reload, legacy migration and price display passed.")
	quit()
