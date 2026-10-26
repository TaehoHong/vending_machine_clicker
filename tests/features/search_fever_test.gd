extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")


class FeverGame:
	extends "res://src/game/game_session.gd"
	var forced_empty: bool = false

	func _roll_drink() -> int:
		return 6

	func _search_is_empty() -> bool:
		return forced_empty


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var game = FIXTURE.create_game(root, FeverGame.new())
	game.session.money = 100
	game._on_shop_button_pressed()
	assert(game.session.search_fever_pending and game.session.search_fever_remaining == 0)
	await FIXTURE.wait_for_purchase_effects(game)
	assert(not game.result_overlay.visible and not game.session.search_fever_pending)
	assert(game.session.search_fever_remaining == 10 and game.session.clicks_required() == 5)
	assert(
		(
			game.session.calculate_reward(10)
			== (10 + game.session.coin_bonus()) * 2
		)
	)
	game._process(0.5)
	assert(is_equal_approx(game.session.search_fever_remaining, 9.5))
	assert(
		(
			game.search_fever_fx.visible
			and game.search_fever_fx.mouse_filter == Control.MOUSE_FILTER_IGNORE
		)
	)
	game.info_overlay.show()
	game._process(3)
	assert(
		(
			is_equal_approx(game.session.search_fever_remaining, 9.5)
			and not game.search_fever_fx.visible
		)
	)
	game.info_overlay.hide()
	game.pause_menu.set_open(true)
	await create_timer(0.08).timeout
	assert(is_equal_approx(game.session.search_fever_remaining, 9.5))
	game.pause_menu.set_open(false)
	game.session.forced_empty = true
	game.session.click_stack = game.session.clicks_required() - 1
	var before: int = game.session.money
	game._on_earn_button_pressed()
	assert(game.session.money == before and game.session.click_stack == 0)
	game.session.extra_counts[12] = 25
	game._start_search_fever()
	assert(game.session.search_fever_remaining == 20)
	game.session.water_count = 30
	game.session.extra_counts[3] = 6
	assert(game.session.clicks_required() == 3)
	game.session.click_stack = 0
	game.session.search_fever_remaining = 0.1
	game._process(0.2)
	assert(game.session.search_fever_remaining == 0 and not game.search_fever_fx.visible)
	assert(game.session.clicks_required() == 8)
	assert(
		(
			game.session.calculate_reward(10)
			== floori((10 + game.session.coin_bonus()) * game.session.reward_multiplier())
		)
	)
	game.free()
	print(
		"Cola trigger, timed fever, stacking, miss, pause, duration cap and expiry checks passed."
	)
	quit()
