extends SceneTree

const SESSION = preload("res://src/game/game_session.gd")
const RULES = preload("res://src/game/automation/facility_rules.gd")
const FIXTURE = preload("res://tests/support/game_fixture.gd")
const SCREEN = preload("res://src/features/facilities/facilities_screen.tscn")

func _initialize() -> void:
	call_deferred("run_checks")
	create_timer(15).timeout.connect(func() -> void: quit(1))


func run_checks() -> void:
	var session := SESSION.new()
	session.money = 1500
	session.cans = 25
	var preview: Control = SCREEN.instantiate()
	root.add_child(preview)
	preview.open(session)
	var before := session.facilities.duplicate(true)
	var money: int = session.money
	var cans: int = session.cans
	preview._preview("auto")
	await process_frame
	preview._preview("trash")
	await process_frame
	assert(session.facilities == before and session.money == money and session.cans == cans)
	preview.free()
	var game = FIXTURE.create_game(root)
	game.session.money = 1000
	game.session.cans = 10
	game._open_facilities()
	var screen: Control = game.facilities_screen
	var buy: Button = screen.actions.auto
	await tap(buy)
	assert(RULES.state(game.session).auto_unlocked and game.session.cans == 0)
	await tap(buy)
	assert(RULES.state(game.session).auto_owned and game.session.money == 0)
	await tap(buy)
	assert(game.session.money == 0)
	var clicks: int = game.session.quest_clicks
	game._on_earn_button_pressed()
	game._on_shop_button_pressed()
	assert(game.session.quest_clicks == clicks and game.session.purchase_count == 0)
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	root.push_input(escape)
	await process_frame
	assert(game.facilities_screen == null and not paused)
	RULES.state(game.session).gold = 10
	game.facility_world.refresh()
	await tap(game.facility_world.gold)
	assert(game.session.money == 10 and RULES.state(game.session).gold == 0)
	game.facility_world.gold.pressed.emit()
	assert(game.session.money == 10)
	RULES.state(game.session).drops = [{"id": 1, "amount": 2, "remaining": 15.0}]
	game.facility_world.refresh()
	await tap(game.facility_world.drops[1])
	assert(game.session.cans == 2 and game.session.drinks == 0)
	var save_path: String = FIXTURE.store_for(game).path
	game.free()
	DirAccess.remove_absolute(save_path)
	print("Facility purchase, upgrades, production, expiry, collection, save and preview passed.")
	quit()


func tap(control: Control) -> void:
	var point := control.get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
		await process_frame
