extends SceneTree

class PunchGame extends "res://game.gd":
	var forced_empty: bool = false
	var forced_drink: int = 14
	func _load_progress() -> void: pass
	func _save_progress() -> void: pass
	func _search_is_empty() -> bool: return forced_empty
	func _roll_drink() -> int: return forced_drink
	func calculate_reward(_base: int) -> int: return super.calculate_reward(10)

func _initialize() -> void:
	call_deferred("run_checks")
	create_timer(20).timeout.connect(func() -> void: quit(1))

func tap(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event)
		await process_frame

func run_checks() -> void:
	var game = load("res://Game.tscn").instantiate()
	game.set_script(PunchGame)
	root.add_child(game)
	game.money = 1000
	game._on_shop_button_pressed()
	assert(game.punch_fever_pending and game.punch_fever_remaining == 0)
	await game.coin_tween.finished
	assert(game.punch_fever_remaining == 5 and game.punch_button.visible)
	assert(root.get_node("CursorTheme").punch_mode)
	await process_frame
	var rect: Rect2 = game.punch_button.get_rect()
	for ratio in [Vector2(0.1,0.1), Vector2(0.5,0.5), Vector2(0.5,0.84), Vector2(0.9,0.95)]:
		var before: int = game.money
		var reward: int = game.calculate_reward(10) * 3
		await tap(rect.position + rect.size * ratio)
		assert(game.money == before + reward, "Every cabinet region must grant a punch reward")
		assert(game.drinks == 1 and not game.inserting_coin, "Punching must not buy drinks")
		assert(not game.punch_fever_fx.hits.is_empty())
		assert(game.last_punch_point.distance_to(rect.position + rect.size * ratio) < 1, "Impact must follow the click location")
	game._clear_search_popups("search_coin_effects")
	game._show_search_coin(245)
	var coins := get_nodes_in_group("search_coin_effects")
	assert(coins.size() == 6)
	var origins := Rect2(coins[0].position, Vector2.ZERO)
	for coin in coins:
		assert(coin.scale == Vector2.ONE * game.FEVER_COIN_SCALE)
		origins = origins.expand(coin.position)
	assert(origins.size.x > rect.size.x * 0.7 and origins.size.y > rect.size.y * 0.7, "Coins must originate around the whole machine")
	game.forced_empty = true
	var before: int = game.money
	game._on_punch_button_pressed()
	assert(game.money == before and get_nodes_in_group("search_coin_effects").is_empty())
	game.forced_empty = false
	game.pause_menu.set_open(true)
	var time: float = game.punch_fever_remaining
	await create_timer(0.08).timeout
	game._on_punch_button_pressed()
	assert(game.money == before and game.punch_fever_remaining == time)
	game.pause_menu.set_open(false)
	game.info_overlay.show()
	game._process(1)
	assert(game.punch_fever_remaining == time and not game.punch_button.visible)
	game.info_overlay.hide()
	game.extra_counts[5] = 100
	game._start_punch_fever()
	assert(game.punch_fever_total == 15)
	game._start_search_fever()
	before = game.money
	game._on_punch_button_pressed()
	assert(game.money == before + game.calculate_reward(10) * 3, "Both fever multipliers must stack")
	game.punch_fever_remaining = 0.01
	game._process(0.02)
	assert(game.punch_fever_remaining == 0 and not game.punch_button.visible)
	assert(not root.get_node("CursorTheme").punch_mode)
	assert(game.get_node("VendingMachine").position == game.machine_home)
	game.search_fever_remaining = 0
	game.forced_drink = 0
	game._on_shop_button_pressed()
	assert(game.inserting_coin and game.drinks == 2, "Regular purchases must return after punch fever")
	await game.coin_tween.finished
	game.free()
	assert(not root.get_node("CursorTheme").punch_mode)
	print("Energy trigger, whole-cabinet clicks, reward, miss, radial coins, size, pause, stacking, duration and normal restoration passed.")
	quit()
