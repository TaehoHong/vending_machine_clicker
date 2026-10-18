extends SceneTree

var failures: int = 0
func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run_checks")
func capture(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://design/godot-applied/skill_%s.png" % name)
func run_checks() -> void:
	var game = load("res://Game.tscn").instantiate()
	game.save_path = "res://.godot/skill_test_%d.cfg" % Time.get_ticks_usec()
	root.add_child(game)
	check(not game.money_label.text.contains("¥") and game.get_node("WalletPanel/Currency").text == "Gold", "Wallet uses plain amount and larger Gold label")
	game._on_ability_button_pressed()
	check(not game.get_node("InfoOverlay/Card/Catalog/Rows/Ion").visible and not game.get_node("InfoOverlay/Card/Summary").text.contains("이온"), "Locked ion is absent from ability catalog and summary")
	await capture("locked_ability")
	game._on_info_close_pressed()
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		check(game.shop_button.get_theme_stylebox(state) is StyleBoxEmpty, "Coin slot never draws a box in any state")
	for i in range(100):
		check(game._roll_drink() < 2, "Ion never drops before unlock")
	for i in range(4):
		game._apply_drink(0)
	game._refresh_ui()
	game.get_node("Navigation/SkillButton").pressed.emit()
	game._on_unlock_ion_pressed()
	check(not game.ion_unlocked and game.cans == 4, "Insufficient cans cannot unlock")
	game._on_info_close_pressed()
	game._apply_drink(1)
	game.money = 600
	game._refresh_ui()
	await capture("hud")
	game._on_skill_button_pressed()
	await capture("available")
	var before_bonus: int = game.coin_bonus()
	var unlock: Button = game.get_node("InfoOverlay/Card/SkillTree").get_unlock_button(2)
	unlock.pressed.emit()
	check(game.ion_unlocked and game.cans == 0 and game.money == 600, "Unlock consumes exactly 5 cans and no Gold")
	check(game.coin_bonus() == before_bonus, "Spending cans preserves earned collection bonuses")
	game._on_unlock_ion_pressed()
	check(game.cans == 0 and unlock.disabled, "Unlocked node cannot be purchased twice")
	await capture("unlocked")
	game._on_info_close_pressed()
	game.quest_reward_claimed = true
	game._refresh_ui()
	check(not game.quest_complete_button.disabled, "Spending cans does not lose the five-can quest milestone")
	var found_ion: bool = false
	seed(12345)
	for i in range(100):
		var drink: int = game._roll_drink()
		check(drink >= 0 and drink <= 2, "Unlocked pool contains exactly three drink types")
		found_ion = found_ion or drink == 2
	check(found_ion, "Ion can drop after unlocking")
	game._save_progress()
	var path: String = game.save_path
	game.free()
	game = load("res://Game.tscn").instantiate()
	game.save_path = path
	root.add_child(game)
	check(game.ion_unlocked and game.cans == 0 and game.drinks == 5, "Reload preserves unlock and does not refund spent cans")
	before_bonus = game.coin_bonus()
	game._apply_drink(2)
	check(game.ion_count == 1 and game.cans == 1 and game.coin_bonus() == before_bonus + 2, "Ion grants one can and a permanent +2 Gold discovery bonus")
	game.last_drink = 2
	game._update_result()
	game.result_overlay.show()
	game._refresh_ui()
	await capture("ion_result")
	game._on_result_close_pressed()
	game._on_ability_button_pressed()
	check(game.get_node("InfoOverlay/Card/Catalog/Rows/Ion").visible and game.get_node("InfoOverlay/Card/Catalog/Rows/Ion/Count").text.contains("1"), "Ability window tracks ion can count")
	await capture("ability")
	game._save_progress()
	var saved := ConfigFile.new()
	check(saved.load(path) == OK and saved.get_value("progress", "ion_count") == 1, "Ion collection is saved")
	game.free()
	DirAccess.remove_absolute(path)
	print("Skill tree checks: %d failures" % failures)
	quit(1 if failures else 0)
