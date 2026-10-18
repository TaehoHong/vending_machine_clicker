extends SceneTree

class FeverGame extends "res://game.gd":
	var forced_empty: bool = false
	func _load_progress() -> void: pass
	func _save_progress() -> void: pass
	func _roll_drink() -> int: return 6
	func _search_is_empty() -> bool: return forced_empty

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game = load("res://Game.tscn").instantiate()
	game.set_script(FeverGame)
	root.add_child(game)
	game.money = 100
	game._on_shop_button_pressed()
	assert(game.search_fever_pending and game.search_fever_remaining == 0)
	await game.coin_tween.finished
	game._on_result_close_pressed()
	assert(game.search_fever_remaining == 10 and game.clicks_required() == 5)
	assert(game.calculate_reward(10) == floori((10 + game.coin_bonus()) * game.reward_multiplier()) * 2)
	game._process(0.5)
	assert(is_equal_approx(game.search_fever_remaining, 9.5))
	assert(game.search_fever_fx.visible and game.search_fever_fx.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	game.info_overlay.show()
	game._process(3)
	assert(is_equal_approx(game.search_fever_remaining, 9.5) and not game.search_fever_fx.visible)
	game.info_overlay.hide()
	game.pause_menu.set_open(true)
	await create_timer(0.08).timeout
	assert(is_equal_approx(game.search_fever_remaining, 9.5))
	game.pause_menu.set_open(false)
	game.forced_empty = true
	game.click_stack = game.clicks_required() - 1
	var before: int = game.money
	game._on_earn_button_pressed()
	assert(game.money == before and game.click_stack == 0)
	game.extra_counts[12] = 25
	game._start_search_fever()
	assert(game.search_fever_remaining == 20)
	game.water_count = 30
	assert(game.clicks_required() == 1)
	game.click_stack = 0
	game.search_fever_remaining = 0.1
	game._process(0.2)
	assert(game.search_fever_remaining == 0 and not game.search_fever_fx.visible)
	assert(game.clicks_required() == 3)
	assert(game.calculate_reward(10) == floori((10 + game.coin_bonus()) * game.reward_multiplier()))
	game.free()
	print("Cola trigger, timed fever, stacking, miss, pause, duration cap and expiry checks passed.")
	quit()
