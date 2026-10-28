extends SceneTree

const SESSION = preload("res://src/game/game_session.gd")
const RULES = preload("res://src/game/automation/facility_rules.gd")
const FIXTURE = preload("res://tests/support/game_fixture.gd")
const SCREEN = preload("res://src/features/facilities/facilities_screen.tscn")
const DESIGN = preload("res://src/shared/ui/design_view.gd")

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
	game.session.money = 2200
	game.session.cans = 25
	game._open_facilities()
	var screen: Control = game.facilities_screen
	await tap(screen.actions.auto)
	assert(RULES.state(game.session).auto_owned and game.session.cans == 15)
	assert(game.session.money == 2200)
	var auto_frame := DESIGN.shape(screen.canvas, "Action / Buy Auto")
	assert(DESIGN.shape(auto_frame, "Label").visible)
	assert(DESIGN.shape(auto_frame, "Label").text == "업그레이드")
	assert(not DESIGN.shape(auto_frame, "Price / Value").visible)
	await tap(screen.actions.auto)
	assert(screen.page == "auto_upgrade")
	await tap(screen.actions.production)
	assert(RULES.state(game.session).production == 1 and game.session.money == 2100)
	screen.go_back()
	assert(screen.page == "purchase")
	await tap(screen.actions.trash)
	assert(RULES.state(game.session).trash_owned and game.session.cans == 0)
	assert(game.session.money == 2100)
	var trash_frame := DESIGN.shape(screen.canvas, "Action / Buy Trash")
	assert(DESIGN.shape(trash_frame, "Label").visible)
	assert(DESIGN.shape(trash_frame, "Label").text == "업그레이드")
	assert(not DESIGN.shape(trash_frame, "Price / Value").visible)
	await tap(screen.actions.trash)
	assert(screen.page == "trash_upgrade")
	await tap(screen.actions.chance)
	assert(RULES.state(game.session).chance == 1 and game.session.money == 2000)
	screen.go_back()
	assert(screen.page == "purchase")
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
	var auto_body := DESIGN.shape(
		game.facility_world, "시설 / 자동 자판기 / 설치 · 02 인스턴스"
	)
	var trash_body := DESIGN.shape(
		game.facility_world, "시설 / 쓰레기통 / 설치 · 02 인스턴스"
	)
	await tap(auto_body)
	assert(game.facilities_screen == null)
	await tap(trash_body)
	assert(game.facilities_screen == null)
	RULES.state(game.session).gold = 10
	RULES.state(game.session).drops = [{"id": 1, "amount": 2, "remaining": 15.0}]
	game.facility_world.refresh()
	await tap(game.facility_world.gold)
	assert(game.session.money == 2010 and RULES.state(game.session).gold == 0)
	game.facility_world.gold.pressed.emit()
	assert(game.session.money == 2010)
	var drop: Button = game.facility_world.drops[1]
	await tap(drop)
	assert(game.session.cans == 2 and game.session.drinks == 0)
	assert(game.session.collect_facility_item(1) == 0)
	assert(game.session.cans == 2)
	var save_path: String = FIXTURE.store_for(game).path
	game.free()
	DirAccess.remove_absolute(save_path)
	print("Facility item purchase, gold upgrades, return and separate world collection passed.")
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
