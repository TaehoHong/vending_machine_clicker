extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")


class PriceGame:
	extends "res://src/game/game_session.gd"

	func _roll_drink() -> int:
		return 0


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var game = FIXTURE.create_game(root, PriceGame.new())
	FIXTURE.store_for(game).path = "res://.godot/price-test.cfg"
	assert(game.session.current_draw_price() == 100)
	game.session.money = 1000
	game._on_shop_button_pressed()
	assert(
		(
			game.session.money == 900
			and game.session.purchase_count == 1
			and game.session.current_draw_price() == 102
		)
	)
	game._on_shop_button_pressed()
	assert(game.session.purchase_count == 2 and game.session.money == 798)
	var saved := ConfigFile.new()
	assert(
		(
			saved.load(FIXTURE.store_for(game).path) == OK
			and saved.get_value("progress", "purchase_count") == 2
		)
	)
	await FIXTURE.wait_for_purchase_effects(game)
	assert(
		(
			game.session.money == 798
			and game.session.purchase_count == 2
			and game.session.current_draw_price() == 105
		)
	)
	game.session.money = 104
	game._on_shop_button_pressed()
	assert(
		(
			game.session.money == 104
			and game.session.purchase_count == 2
			and not game.session.inserting_coin
		)
	)
	game.session.money = 105
	game._on_shop_button_pressed()
	assert(
		(
			game.session.money == 0
			and game.session.purchase_count == 3
			and game.session.current_draw_price() == 107
		)
	)
	await FIXTURE.wait_for_purchase_effects(game)
	game._save_progress()
	var loaded = FIXTURE.create_game(root)
	FIXTURE.store_for(loaded).path = FIXTURE.store_for(game).path
	FIXTURE.store_for(loaded).load_into(loaded.session)
	loaded._refresh_ui()
	assert(loaded.session.purchase_count == 3 and loaded.session.current_draw_price() == 107)
	var legacy := ConfigFile.new()
	legacy.set_value("progress", "drinks", 6)
	legacy.save(FIXTURE.store_for(game).path)
	FIXTURE.store_for(loaded).load_into(loaded.session)
	assert(loaded.session.purchase_count == 6 and loaded.session.current_draw_price() == 113)
	loaded.session.purchase_count = 233
	assert(loaded.session.current_draw_price() == 10089)
	loaded._refresh_ui()
	assert(loaded.price_label.text == "10.0K")
	loaded.free()
	game.free()
	DirAccess.remove_absolute("res://.godot/price-test.cfg")
	print(
		"2 percent compounding, atomic charge/save, insufficient funds, "
		+ "reload, legacy migration and price display passed."
	)
	quit()
