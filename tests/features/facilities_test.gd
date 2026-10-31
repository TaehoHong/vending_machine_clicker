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
	var can_wallet := DESIGN.shape(preview.canvas, "Header / Cans")
	assert(can_wallet != null, "시설 구매창 안에서 구매 재화의 보유량을 표시해야 합니다.")
	assert(can_wallet.text == "25")
	session.money = 9223372036854775807
	session.cans = 1000000000
	preview.refresh()
	for name: String in ["Header / Wallet", "Header / Cans"]:
		var value: Label = DESIGN.shape(preview.canvas, name)
		var rendered_width := value.get_theme_font("font").get_string_size(
			value.text, HORIZONTAL_ALIGNMENT_LEFT, -1, value.get_theme_font_size("font_size")
		).x
		assert(rendered_width <= value.size.x, "큰 보유량도 재화 단위까지 잘리지 않아야 합니다.")
	session.money = 1500
	session.cans = 25
	preview.refresh()
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
	assert(DESIGN.shape(screen.canvas, "Upgrade / production / Current").text == "10")
	assert(DESIGN.shape(screen.canvas, "Upgrade / production / Next").text == "20 Gold/회")
	await tap(screen.actions.production)
	assert(RULES.state(game.session).production == 1 and game.session.money == 2100)
	assert(DESIGN.shape(screen.canvas, "Upgrade / production / Current").text == "20")
	assert(DESIGN.shape(screen.canvas, "Upgrade / production / Next").text == "30 Gold/회")
	assert(DESIGN.shape(screen.canvas, "Upgrade / production / Level").text == "1/5")
	assert(DESIGN.shape(screen.actions.production.get_parent(), "Label").text == "200")
	assert(DESIGN.shape(screen.canvas, "Header / Cans").text == "15")
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
	var collection_hint := DESIGN.shape(screen.canvas, "Upgrade / capacity / Hint")
	assert(collection_hint.visible)
	RULES.state(game.session).items = 1
	screen.refresh()
	assert(not collection_hint.visible)
	await tap(screen.actions.chance)
	assert(RULES.state(game.session).chance == 1 and game.session.money == 2000)
	assert(DESIGN.shape(screen.canvas, "Upgrade / chance / Current").text == "60%")
	assert(DESIGN.shape(screen.canvas, "Upgrade / chance / Next").text == "70%")
	game.session.money = 199
	screen.refresh()
	assert(screen.actions.chance.disabled)
	assert(DESIGN.shape(screen.canvas, "Upgrade / chance / Shortage").visible)
	await tap(screen.actions.chance)
	assert(game.session.money == 199 and RULES.state(game.session).chance == 1)
	RULES.state(game.session).chance = 5
	screen.refresh()
	assert(DESIGN.shape(screen.canvas, "Upgrade / chance / Max").visible)
	assert(not screen.actions.chance.get_parent().visible)
	assert(not DESIGN.shape(screen.canvas, "Upgrade / chance / Next").visible)
	game.session.money = 2000
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
	RULES.state(game.session).drops = [{"id": 1, "amount": 2, "remaining": 15.0}]
	game.facility_world.refresh()
	var drop: Button = game.facility_world.drops[1]
	assert(drop.get_tooltip().is_empty(), "Dropped cans have no hover popup")
	var drop_start: Vector2 = drop.position
	game.pause_menu.set_open(true)
	await create_timer(0.05).timeout
	assert(drop.position == drop_start, "Can motion follows the gameplay pause")
	game.pause_menu.set_open(false)
	await create_timer(0.85).timeout
	assert(drop.position.x < drop_start.x, "The can rolls sideways after falling")
	assert(is_equal_approx(drop.rotation, -TAU - PI * 0.5), "The can settles lying down")
	var bottom: float = drop.position.y + drop.pivot_offset.y + drop.size.x * 0.5
	assert(is_equal_approx(bottom, game.facility_world.customer_flow.reward_origin().y))
	game._open_facilities()
	await tap(drop)
	assert(game.session.cans == 0 and RULES.state(game.session).drops.size() == 1,
		"시설창 뒤에 있는 빈캔은 모달 위에서 클릭해도 수령하지 않아야 합니다.")
	game.facilities_screen.close()
	await process_frame
	await tap(drop)
	assert(game.session.cans == 2 and game.session.drinks == 0)
	assert(game.session.collect_facility_item(1) == 0)
	assert(game.session.cans == 2)
	var can_preferences: Node = root.get_node("Preferences")
	var can_reduced_before: bool = can_preferences.values.reduce_motion
	can_preferences.values.reduce_motion = true
	RULES.state(game.session).drops = [{"id": 2, "amount": 1, "remaining": 15.0}]
	game.facility_world.refresh()
	var still_drop: Button = game.facility_world.drops[2]
	assert(is_equal_approx(still_drop.rotation, -PI * 0.5))
	assert(still_drop.position.y > 450, "Reduced motion uses the same floor without falling")
	can_preferences.values.reduce_motion = can_reduced_before
	RULES.state(game.session).drops.clear()
	game.facility_world.refresh()
	game.set_process(false)
	var receipts: Array[Vector2i] = []
	game.facility_world.changed.connect(func() -> void:
		if game.session.money > 2000:
			receipts.append(Vector2i(game.session.money, RULES.state(game.session).gold))
	)
	game.facility_world.advance(10.0)
	game.facility_world.advance(10.0)
	assert(game.session.money == 2000 and RULES.state(game.session).gold == 40)
	await create_timer(1.0).timeout
	assert(game.session.money == 2040, "생산 골드는 클릭 없이 연출 후 자동 수령해야 합니다.")
	assert(receipts == [Vector2i(2020, 20), Vector2i(2040, 0)],
		"각 연출은 뒤 생산분을 먼저 수령하지 않고 자신의 금액만 지급해야 합니다.")
	var saved := ConfigFile.new()
	var save_path: String = FIXTURE.store_for(game).path
	assert(saved.load(save_path) == OK)
	assert(saved.get_value("progress", "money") == 2040)
	assert(saved.get_value("progress", "facilities").alley.gold == 0)
	game.facility_world.advance(10.0)
	assert(saved.load(save_path) == OK)
	assert(saved.get_value("progress", "money") == 2040)
	assert(saved.get_value("progress", "facilities").alley.gold == 20)
	game.free()
	var app: Control = preload("res://src/app/main.tscn").instantiate()
	app.save_path = save_path
	root.add_child(app)
	app._start_game(false)
	assert(app.session.money == 2060 and RULES.state(app.session).gold == 0,
		"연출 중 종료한 골드는 재진입 때 한 번 자동 수령해야 합니다.")
	app.free()
	app = preload("res://src/app/main.tscn").instantiate()
	app.save_path = save_path
	root.add_child(app)
	app._start_game(false)
	assert(app.session.money == 2060 and RULES.state(app.session).gold == 0,
		"복구 후 다시 재진입해도 같은 골드를 중복 지급하지 않아야 합니다.")
	var preferences: Node = root.get_node("Preferences")
	var reduced_before: bool = preferences.values.reduce_motion
	preferences.values.reduce_motion = true
	app.view.set_process(false)
	app.view.facility_world.advance(10.0)
	await create_timer(1.0).timeout
	assert(app.session.money == 2080 and RULES.state(app.session).gold == 0,
		"모션 감소에서도 같은 생산액을 클릭 없이 한 번만 지급해야 합니다.")
	app.view.facility_world.advance(10.0)
	paused = true
	await create_timer(0.3).timeout
	assert(app.session.money == 2080 and RULES.state(app.session).gold == 20,
		"ESC 일시정지 중에는 진행 중인 골드 연출과 수령을 보류해야 합니다.")
	paused = false
	await create_timer(1.0).timeout
	assert(app.session.money == 2100 and RULES.state(app.session).gold == 0,
		"재개한 골드 연출은 같은 보상을 한 번만 지급해야 합니다.")
	preferences.values.reduce_motion = reduced_before
	app.free()
	DirAccess.remove_absolute(save_path)
	print("Facility purchase, upgrades, automatic gold, overlapping payouts and reload passed.")
	quit()


func tap(control: Control) -> void:
	var point := control.get_global_transform_with_canvas() * (control.size * 0.5)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
		await process_frame
