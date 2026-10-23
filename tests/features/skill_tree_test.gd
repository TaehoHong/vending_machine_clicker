extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")

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
		var folder: String = "res://.godot/test_artifacts/skill_tree_test"
		DirAccess.make_dir_recursive_absolute(folder)
		root.get_texture().get_image().save_png(folder.path_join("%s.png" % name))


func run_checks() -> void:
	var game = FIXTURE.create_game(root)
	FIXTURE.store_for(game).path = "res://.godot/skill_test_%d.cfg" % Time.get_ticks_usec()
	check(
		(
			not game.money_label.text.contains("¥")
			and game.get_node("WalletPanel/Currency").text == "Gold"
		),
		"Wallet uses plain amount and larger Gold label"
	)
	game._on_ability_button_pressed()
	var screen = game.get_node("InfoOverlay/Card/SkillTree")
	screen.select_drink(2)
	check(
		(
			screen.products[2].visible
			and screen.buttons[2].disabled
			and screen.buttons[2].text == "5개로 추가"
			and screen.detail_count.text == "미해금"
		),
		"Locked ion stays visible and requires five cans"
	)
	await capture("locked_ability")
	game._on_info_close_pressed()
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		check(
			game.shop_button.get_theme_stylebox(state) is StyleBoxEmpty,
			"Coin slot never draws a box in any state"
		)
	for i in range(100):
		check(game.session._roll_drink() < 2, "Ion never drops before unlock")
	for i in range(4):
		game.session._apply_drink(0)
	game._refresh_ui()
	game.get_node("Navigation/AbilityButton").pressed.emit()
	game._on_unlock_ion_pressed()
	check(
		not game.session.ion_unlocked and game.session.cans == 4, "Insufficient cans cannot unlock"
	)
	game._on_info_close_pressed()
	game.session._apply_drink(1)
	game.session.money = 600
	game._refresh_ui()
	await capture("hud")
	game._on_skill_button_pressed()
	await capture("available")
	var before_bonus: int = game.session.coin_bonus()
	var unlock: Button = game.get_node("InfoOverlay/Card/SkillTree").get_unlock_button(2)
	unlock.pressed.emit()
	check(
		game.session.ion_unlocked and game.session.cans == 0 and game.session.money == 600,
		"Unlock consumes exactly 5 cans and no Gold"
	)
	check(
		game.session.coin_bonus() == before_bonus,
		"Spending cans preserves earned collection bonuses"
	)
	game._on_unlock_ion_pressed()
	check(game.session.cans == 0 and unlock.disabled, "Unlocked node cannot be purchased twice")
	await capture("unlocked")
	game._on_info_close_pressed()
	game.session.quest_reward_claimed = true
	game._refresh_ui()
	check(
		not game.quest_complete_button.disabled,
		"Spending cans does not lose the five-can quest milestone"
	)
	var found_ion: bool = false
	seed(12345)
	for i in range(100):
		var drink: int = game.session._roll_drink()
		check(drink >= 0 and drink <= 2, "Unlocked pool contains exactly three drink types")
		found_ion = found_ion or drink == 2
	check(found_ion, "Ion can drop after unlocking")
	game._save_progress()
	var path: String = FIXTURE.store_for(game).path
	game.free()
	game = FIXTURE.create_game(root)
	FIXTURE.store_for(game).path = path
	FIXTURE.store_for(game).load_into(game.session)
	game._refresh_ui()
	check(
		game.session.ion_unlocked and game.session.cans == 0 and game.session.drinks == 5,
		"Reload preserves unlock and does not refund spent cans"
	)
	before_bonus = game.session.coin_bonus()
	game.session._apply_drink(2)
	check(
		(
			game.session.ion_count == 1
			and game.session.cans == 1
			and game.session.coin_bonus() == before_bonus
			and game.session.coin_weights() == [6900, 960, 530, 110, 1500]
		),
		"Ion grants one can and shifts discovery probabilities without a Gold bonus"
	)
	game.session.last_drink = 2
	game._update_result()
	game.result_overlay.show()
	game._refresh_ui()
	await capture("ion_result")
	game._on_result_close_pressed()
	game._on_ability_button_pressed()
	screen = game.get_node("InfoOverlay/Card/SkillTree")
	screen.select_drink(2)
	check(
		screen.detail_count.text.contains("1") and not screen.buttons[2].visible,
		"Acquired ion shows one can and no repeated unlock button"
	)
	await capture("ability")
	game._save_progress()
	var saved := ConfigFile.new()
	check(
		saved.load(path) == OK and saved.get_value("progress", "ion_count") == 1,
		"Ion collection is saved"
	)
	game.free()
	DirAccess.remove_absolute(path)
	print("Skill tree checks: %d failures" % failures)
	quit(1 if failures else 0)
