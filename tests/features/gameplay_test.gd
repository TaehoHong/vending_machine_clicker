extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")


class TestGame:
	extends "res://src/game/game_session.gd"
	var persistence_enabled: bool = false
	var forced_drink: int = 0

	func _roll_drink() -> int:
		return forced_drink


var failures: int = 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var game = FIXTURE.create_game(root, TestGame.new())
	FIXTURE.store_for(game).path = "res://.godot/draw_test_%d.cfg" % Time.get_ticks_usec()
	game.session.persistence_enabled = true
	game.session.money = 99
	game.shop_button.pressed.emit()
	check(
		game.session.money == 99 and game.session.drinks == 0 and not game.session.inserting_coin,
		"Insufficient funds never charge or grant drinks"
	)
	game.session.money = 307
	game._refresh_ui()
	game.shop_button.pressed.emit()
	check(
		game.session.money == 207 and game.session.water_count == 1 and game.session.cans == 1,
		"Click immediately charges 100 yen and grants water"
	)
	check(
		(
			game.session.inserting_coin
			and not game._purchase_effects.is_empty()
			and not game.result_overlay.visible
		),
		"Coin animation precedes result"
	)
	var committed := ConfigFile.new()
	check(
		(
			committed.load(FIXTURE.store_for(game).path) == OK
			and committed.get_value("progress", "money") == 207
			and committed.get_value("progress", "water_count") == 1
		),
		"Charge and reward persist together before animation completes"
	)
	await FIXTURE.wait_for_purchase_effects(game)
	await process_frame
	check(
		(
			not game.result_overlay.visible
			and game._purchase_effects.is_empty()
		),
		"Purchase completes without a popup"
	)
	check(
		not game.shop_button.disabled and not game.ability_toast.visible,
		"Drink reaches ability button without an acquisition toast"
	)
	game.session.forced_drink = 1
	game.shop_button.pressed.emit()
	check(
		(
			game.session.money == 105
			and game.session.green_tea_count == 1
			and game.session.drinks == 2
			and game.session.cans == 2
		),
		"Second drink costs 102 Gold"
	)
	check(game.session.coin_bonus() == 4, "Water +1 and green tea +3 add to discovered coin value")
	await FIXTURE.wait_for_purchase_effects(game)
	await process_frame
	check(
		not game.result_overlay.visible and not game.ability_toast.visible,
		"Tea arrives without an acquisition toast"
	)
	game.session.forced_drink = 0
	game.shop_button.pressed.emit()
	check(game.session.money == 0, "Exact 105 Gold balance can buy the third drink")
	await FIXTURE.wait_for_purchase_effects(game)
	await process_frame
	game._on_shop_button_pressed()
	check(
		game.session.money == 0 and game.session.drinks == 3 and not game.session.inserting_coin,
		"Zero balance cannot buy"
	)
	game.session._apply_drink(0)
	check(game.session.clicks_required() == 10, "Water changes Gold, never search clicks")
	check(not game.has_node("ShopPanel/Margin/Items/UpgradeButton"), "Upgrade remains removed")
	game.session.quest_clicks = 10
	game._on_quest_complete_button_pressed()
	game._on_quest_complete_button_pressed()
	check(
		(
			game.session.money == 5000
			and game.quest_progress.visible
			and not game.session.can_quest_reward_claimed
		),
		"First quest pays once and advances to can quest"
	)
	game._save_progress()
	game.session.water_count = 0
	game.session.green_tea_count = 0
	game.session.money = 0
	FIXTURE.store_for(game).load_into(game.session)
	check(
		(
			game.session.money == 5000
			and game.session.water_count == 3
			and game.session.green_tea_count == 1
		),
		"Both drink types survive reload"
	)
	var legacy := ConfigFile.new()
	legacy.set_value("progress", "drinks", 6)
	legacy.save(FIXTURE.store_for(game).path)
	FIXTURE.store_for(game).load_into(game.session)
	check(
		(
			game.session.water_count == 6
			and game.session.green_tea_count == 0
			and game.session.clicks_required() == 10
		),
		"Older saves retain existing water progress"
	)
	DirAccess.remove_absolute(FIXTURE.store_for(game).path)
	var old_slot_position: Vector2 = game.shop_button.position
	game.size = Vector2(1280, 720)
	game._position_coin_slot()
	check(game.shop_button.position != old_slot_position, "Coin slot follows background resizing")
	game.free()
	print("Gameplay checks: %d failures" % failures)
	quit(1 if failures else 0)
