extends SceneTree

const COIN = preload("res://ui/search_coin.gd")
class RewardGame extends "res://game.gd":
	func _load_progress() -> void: pass
	func _save_progress() -> void: pass
	func _search_is_empty() -> bool: return false
	func calculate_reward(_base_amount: int) -> int: return 245

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var cases := {
		0: [0, 0, 0, 0], 1: [1, 0, 0, 0], 9: [1, 0, 0, 0],
		10: [1, 0, 0, 0], 19: [1, 0, 0, 0], 20: [2, 0, 0, 0],
		99: [9, 0, 0, 0], 100: [0, 1, 0, 0], 105: [1, 1, 0, 0],
		200: [0, 2, 0, 0], 245: [4, 2, 0, 0], 1000: [0, 0, 1, 0],
		1245: [4, 2, 1, 0], 12345: [4, 3, 2, 1]
	}
	for amount in cases:
		assert(COIN.breakdown(amount) == cases[amount], "Incorrect coin breakdown for %d" % amount)
	var game = load("res://Game.tscn").instantiate()
	game.set_script(RewardGame)
	root.add_child(game)
	game.click_stack = game.clicks_required() - 1
	game.earn_button.pressed.emit()
	assert(game.money == 245, "All Gold including the remainder must be granted")
	var counts := [0, 0, 0, 0]
	for coin in get_nodes_in_group("search_coin_effects"):
		counts[coin.tier] += 1
	assert(counts == [4, 2, 0, 0], "245 Gold must spawn four bronze and two silver coins")
	for coin in get_nodes_in_group("search_coin_effects"):
		assert(coin.scale == Vector2.ONE, "Normal search coin size must stay unchanged")
	game._clear_search_popups("search_coin_effects")
	game._start_search_fever()
	game._show_search_coin(245)
	var burst := get_nodes_in_group("search_coin_effects")
	assert(burst.size() == 6)
	for coin in burst:
		assert(coin.scale == Vector2.ONE * 2.5, "Fever coins must be 2.5 times normal size")
	game._show_search_coin(245)
	assert(get_nodes_in_group("search_coin_effects").size() == 12, "Consecutive fever bursts must finish their flight")
	await create_timer(0.45).timeout
	var left := INF
	var right := -INF
	for coin in burst:
		left = minf(left, coin.position.x)
		right = maxf(right, coin.position.x)
	assert(right - left > 200, "Fever coins must scatter broadly")
	await create_timer(0.85).timeout
	assert(get_nodes_in_group("search_coin_effects").is_empty(), "Fever bursts must clean themselves up")
	game._show_search_coin(245)
	game._show_empty_search()
	assert(get_nodes_in_group("search_coin_effects").is_empty())
	assert(get_nodes_in_group("empty_search_popups").size() == 1)
	game.free()
	print("Coin denomination, exact payout and miss cleanup checks passed.")
	quit()
