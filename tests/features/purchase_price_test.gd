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
			and game.session.current_draw_price() == 105
		)
	)
	game._on_shop_button_pressed()
	assert(game.session.purchase_count == 1)
	var saved := ConfigFile.new()
	assert(
		(
			saved.load(FIXTURE.store_for(game).path) == OK
			and saved.get_value("progress", "purchase_count") == 1
		)
	)
	await game.coin_tween.finished
	game._on_shop_button_pressed()
	assert(
		(
			game.session.money == 795
			and game.session.purchase_count == 2
			and game.session.current_draw_price() == 111
		)
	)
	await game.coin_tween.finished
	game.session.money = 110
	game._on_shop_button_pressed()
	assert(
		(
			game.session.money == 110
			and game.session.purchase_count == 2
			and not game.session.inserting_coin
		)
	)
	game.session.money = 111
	game._on_shop_button_pressed()
	assert(
		(
			game.session.money == 0
			and game.session.purchase_count == 3
			and game.session.current_draw_price() == 116
		)
	)
	await game.coin_tween.finished
	game._save_progress()
	var loaded = FIXTURE.create_game(root)
	FIXTURE.store_for(loaded).path = FIXTURE.store_for(game).path
	FIXTURE.store_for(loaded).load_into(loaded.session)
	loaded._refresh_ui()
	assert(loaded.session.purchase_count == 3 and loaded.session.current_draw_price() == 116)
	var legacy := ConfigFile.new()
	legacy.set_value("progress", "drinks", 6)
	legacy.save(FIXTURE.store_for(game).path)
	FIXTURE.store_for(loaded).load_into(loaded.session)
	assert(loaded.session.purchase_count == 6 and loaded.session.current_draw_price() == 135)
	loaded.session.purchase_count = 99
	assert(loaded.session.current_draw_price() == 12524)
	loaded._refresh_ui()
	assert(loaded.get_node("SlotHint/Price").text == "12.5K G")
	loaded.free()
	game.free()
	DirAccess.remove_absolute("res://.godot/price-test.cfg")
	print(
		"5 percent compounding, atomic purchase/save, duplicate and insufficient funds, reload, legacy migration and price display passed."
	)
	quit()
