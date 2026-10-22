extends SceneTree

const FIXTURE = preload("res://tests/support/game_fixture.gd")


class SearchGame:
	extends "res://src/game/game_session.gd"
	var empty_search: bool = true

	func _search_is_empty() -> bool:
		return empty_search


var failures: int = 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _initialize() -> void:
	call_deferred("run_checks")


func capture(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var folder: String = "res://.godot/test_artifacts/search_test"
		DirAccess.make_dir_recursive_absolute(folder)
		root.get_texture().get_image().save_png(folder.path_join("%s.png" % name))


func run_checks() -> void:
	var game = FIXTURE.create_game(root, SearchGame.new())
	await create_timer(0.22).timeout
	check(
		game.feedback_label.text.is_empty() and not game.earn_button.has_node("Title"),
		"Old bottom instructions and visible search controls are removed"
	)
	check(game.search_glow.modulate.a == 0.0, "Search starts dark")
	check(
		not game.earn_button.get_global_rect().intersects(game.shop_button.get_global_rect()),
		"Search region does not intercept coin slot"
	)
	await capture("dark")
	for i in range(8):
		game.earn_button.pressed.emit()
	await create_timer(0.22).timeout
	check(
		is_equal_approx(game.search_glow.modulate.a, 0.8) and game.session.money == 0,
		"Repeated clicks increase brightness before reward"
	)
	await capture("bright")
	for i in range(2):
		game.earn_button.pressed.emit()
	await create_timer(0.22).timeout
	check(
		(
			game.session.click_stack == 0
			and game.search_glow.modulate.a == 0.0
			and game.session.money == 0
			and game.session.quest_clicks == 0
			and game.session.cans == 0
		),
		"An empty search resets progress and grants nothing"
	)
	var misses: Array[Node] = get_nodes_in_group("empty_search_popups")
	check(
		misses.size() == 1 and misses[0] is TextureRect and game.feedback_label.text.is_empty(),
		"Empty search shows crying icon without bottom text"
	)
	game._show_coin_reward(1)
	game._show_empty_search()
	check(
		get_nodes_in_group("coin_reward_popups").is_empty(),
		"A miss clears previous yen popups so only the crying icon remains"
	)
	await capture("empty")
	game.session.empty_search = false
	for i in range(game.session.clicks_required() - 1):
		game.earn_button.pressed.emit()
	check(
		(
			game.session.money == 0
			and game.session.quest_clicks == 0
			and get_nodes_in_group("coin_reward_popups").is_empty()
		),
		"Clicks after a miss cannot reroll before a full search"
	)
	check(
		get_nodes_in_group("empty_search_popups").size() == 1,
		"Miss icon appears only once per completed search"
	)
	game.earn_button.pressed.emit()
	await create_timer(0.22).timeout
	check(
		(
			game.session.money > 0
			and game.session.click_stack == 0
			and game.search_glow.modulate.a == 0.0
		),
		"Finding a coin returns the area to darkness"
	)
	await capture("reward")
	var popups: Array[Node] = get_nodes_in_group("coin_reward_popups")
	check(
		popups.size() == 1 and popups[0].text == "+%d" % game.session.money,
		"Coin reward shows only the acquired amount"
	)
	check(game.feedback_label.text.is_empty(), "Coin reward no longer appears as bottom text")
	var popup: Label = popups[0]
	var previous_y: float = popup.position.y
	await create_timer(0.35).timeout
	check(popup.position.y < previous_y and popup.modulate.a < 1.0, "Reward rises and fades")
	await create_timer(0.5).timeout
	check(
		(
			get_nodes_in_group("coin_reward_popups").is_empty()
			and get_nodes_in_group("empty_search_popups").is_empty()
		),
		"Expired coin and crying popups are removed"
	)
	game.pause_menu.set_open(true)
	game._on_earn_button_pressed()
	check(game.session.click_stack == 0, "Pause blocks hidden search button")
	game.pause_menu.set_open(false)
	var old_position: Vector2 = game.earn_button.position
	game.size = Vector2(1280, 720)
	game._position_coin_slot()
	check(
		game.earn_button.position != old_position, "Invisible region follows background on resize"
	)
	game.free()
	print("Search checks: %d failures" % failures)
	quit(1 if failures else 0)
