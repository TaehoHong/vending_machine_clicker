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
	RULES.state(game.session).gold = 10
	RULES.state(game.session).drops = [{"id": 1, "amount": 2, "remaining": 15.0}]
	game.facility_world.refresh()
	assert(not game.facility_world.gold is Button, "Facility Gold needs no click")
	assert(game.session.money == 2000, "Gold remains pending until the pop finishes")
	game.facility_world.gold_animation.pause()
	var start: Vector2 = game.facility_world.gold.position
	game.facility_world.gold_animation.custom_step(0.1)
	assert(game.facility_world.gold.position.y < start.y)
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/test_artifacts/facility-gold-pop.png")
	var origin: Vector2 = game.facility_world.gold.position
	game.facility_world.gold_animation.play()
	game.pause_menu.set_open(true)
	await create_timer(0.05).timeout
	assert(game.facility_world.gold.position == origin and game.session.money == 2000)
	game.pause_menu.set_open(false)
	game.facility_world.gold_animation.pause()
	game.facility_world.gold_animation.custom_step(1.0)
	assert(game.session.money == 2010 and RULES.state(game.session).gold == 0)
	game.facility_world._complete_gold_reward()
	assert(game.session.money == 2010, "Completion cannot pay twice")
	assert(game.session.cans == 0, "A dropped can needs a click without trash collection")
	var drop: Button = game.facility_world.drops[1]
	await tap(drop)
	assert(game.session.cans == 2 and game.session.drinks == 0)
	assert(game.session.collect_facility_item(1) == 0)
	assert(game.session.cans == 2)
	# Interrupted pops keep pending Gold in the existing save contract.
	RULES.state(game.session).gold = 30
	game.facility_world.refresh()
	game._save_progress()
	var store: RefCounted = FIXTURE.store_for(game)
	game.free()
	game = FIXTURE.create_game(root)
	store.load_into(game.session)
	game.facility_world.refresh()
	assert(game.session.money == 2010 and game.facility_world.gold.visible)
	await game.facility_world.gold_animation.finished
	assert(game.session.money == 2040 and RULES.state(game.session).gold == 0)
	var restored: RefCounted = SESSION.new()
	FIXTURE.store_for(game).load_into(restored)
	assert(restored.money == 2040 and RULES.state(restored).gold == 0)
	DirAccess.remove_absolute(store.path)
	var save_path: String = FIXTURE.store_for(game).path
	game.free()
	DirAccess.remove_absolute(save_path)
	var production_game = FIXTURE.create_game(root)
	var production: Dictionary = RULES.state(production_game.session)
	production.auto_owned = true
	production.remaining = 0.01
	production_game.facility_world.advance(0.01)
	assert(production.gold == 10 and production_game.session.money == 0)
	assert(production_game.facility_world.gold.visible)
	await production_game.facility_world.gold_animation.finished
	assert(production_game.session.money == 10 and production.gold == 0)
	production_game.facility_world.advance(20.0)
	assert(production.gold == 20, "Multiple elapsed cycles share the existing pending amount")
	await production_game.facility_world.gold_animation.finished
	assert(production_game.session.money == 30 and production.gold == 0)
	var production_path: String = FIXTURE.store_for(production_game).path
	production_game.free()
	DirAccess.remove_absolute(production_path)
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
