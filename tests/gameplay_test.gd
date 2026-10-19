extends SceneTree

class TestGame extends "res://game.gd":
	var persistence_enabled: bool = false
	var forced_drink: int = 0
	func _roll_drink() -> int:
		return forced_drink
	func _save_progress() -> void:
		if persistence_enabled:
			super()
	func _load_progress() -> void:
		if persistence_enabled:
			super()

var failures: int = 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game = load("res://Game.tscn").instantiate()
	game.set_script(TestGame)
	root.add_child(game)
	game.save_path = "res://.godot/draw_test_%d.cfg" % Time.get_ticks_usec()
	game.persistence_enabled = true
	game.money = 99
	game.shop_button.pressed.emit()
	check(game.money == 99 and game.drinks == 0 and not game.inserting_coin, "Insufficient funds never charge or grant drinks")
	game.money = 316
	game._refresh_ui()
	game.shop_button.pressed.emit()
	check(game.money == 216 and game.water_count == 1 and game.cans == 1, "Click immediately charges 100 yen and grants water")
	check(game.inserting_coin and game.coin_token.visible and not game.result_overlay.visible, "Coin animation precedes result")
	var committed := ConfigFile.new()
	check(committed.load(game.save_path) == OK and committed.get_value("progress", "money") == 216 and committed.get_value("progress", "water_count") == 1, "Charge and reward persist together before animation completes")
	game._on_shop_button_pressed()
	check(game.money == 216 and game.drinks == 1, "Repeated clicks during animation do not charge twice")
	await game.coin_tween.finished
	await process_frame
	check(not game.result_overlay.visible and not game.coin_token.visible and not game.drink_dispense_fx.visible, "Purchase completes without a popup")
	check(not game.shop_button.disabled and game.ability_toast.title.text.contains("물"), "Drink reaches ability button and its effect is shown")
	game.forced_drink = 1
	game.shop_button.pressed.emit()
	check(game.money == 111 and game.green_tea_count == 1 and game.drinks == 2 and game.cans == 2, "Second drink costs 105 Gold")
	check(game.coin_bonus() == 1, "Green tea increases discovered coin value")
	await game.coin_tween.finished
	await process_frame
	check(not game.result_overlay.visible and game.ability_toast.title.text.contains("녹차"), "Tea arrives and its effect is shown")
	game.forced_drink = 0
	game.shop_button.pressed.emit()
	check(game.money == 0, "Exact 111 Gold balance can buy the third drink")
	await game.coin_tween.finished
	await process_frame
	game._on_shop_button_pressed()
	check(game.money == 0 and game.drinks == 3 and not game.inserting_coin, "Zero balance cannot buy")
	game._apply_drink(0)
	check(game.clicks_required() == 9, "Three waters reduce search clicks")
	check(not game.has_node("ShopPanel/Margin/Items/UpgradeButton"), "Upgrade remains removed")
	game.quest_clicks = 10
	game._on_quest_complete_button_pressed()
	game._on_quest_complete_button_pressed()
	check(game.money == 5000 and game.quest_progress.visible and not game.can_quest_reward_claimed, "First quest pays once and advances to can quest")
	game._save_progress()
	game.water_count = 0
	game.green_tea_count = 0
	game.money = 0
	game._load_progress()
	check(game.money == 5000 and game.water_count == 3 and game.green_tea_count == 1, "Both drink types survive reload")
	var legacy := ConfigFile.new()
	legacy.set_value("progress", "drinks", 6)
	legacy.save(game.save_path)
	game._load_progress()
	check(game.water_count == 6 and game.green_tea_count == 0 and game.clicks_required() == 8, "Older saves retain existing water progress")
	DirAccess.remove_absolute(game.save_path)
	var old_slot_position: Vector2 = game.shop_button.position
	game.size = Vector2(1280, 720)
	game._position_coin_slot()
	check(game.shop_button.position != old_slot_position, "Coin slot follows background resizing")
	game.free()
	print("Gameplay checks: %d failures" % failures)
	quit(1 if failures else 0)
