extends Control

signal changed
signal closed

const DESIGN = preload("res://src/shared/ui/design_view.gd")
const RULES = preload("res://src/game/automation/facility_rules.gd")
const AMOUNTS = preload("res://src/shared/formatting/amount_format.gd")
const VIEWS = {
	"purchase": preload("res://src/features/facilities/purchase_design.tscn"),
	"auto_upgrade": preload("res://src/features/facilities/auto_upgrade_design.tscn"),
	"trash_upgrade": preload("res://src/features/facilities/trash_upgrade_design.tscn"),
}
var session: RefCounted
var canvas: Control
var page: String = "purchase"
var actions: Dictionary = {}
var previous_focus: Control
var preview_tween: Tween
var preview_origins: Dictionary = {}


func _ready() -> void:
	resized.connect(_layout)


func open(game_session: RefCounted) -> void:
	session = game_session
	previous_focus = get_viewport().gui_get_focus_owner()
	_show_page("purchase")


func _show_page(next: String) -> void:
	page = next
	if is_instance_valid(preview_tween):
		preview_tween.kill()
	preview_origins.clear()
	actions.clear()
	if is_instance_valid(canvas):
		remove_child(canvas)
		canvas.queue_free()
	canvas = VIEWS[page].instantiate()
	add_child(canvas)
	_layout()
	if page == "purchase":
		DESIGN.action(canvas, "Action / Close", close)
		for entry in [["Auto", "auto"], ["Trash", "trash"]]:
			actions[entry[1]] = DESIGN.action(
				canvas, "Action / Buy " + entry[0], _purchase.bind(entry[1])
			)
			DESIGN.action(canvas, "Preview / " + entry[0], _preview.bind(entry[1]))
			var frame := DESIGN.shape(canvas, "Action / Buy " + entry[0])
			var currency := DESIGN.shape(frame, "Price / Currency")
			var can := TextureRect.new()
			can.name = "UnlockCan"
			can.texture = preload("res://src/shared/ui/icons/hud_buttons/icons/can.svg")
			can.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			can.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			can.mouse_filter = Control.MOUSE_FILTER_IGNORE
			currency.add_child(can)
			can.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		var hint := DESIGN.shape(canvas, "키보드 조작 / 돌아가기")
		if hint != null:
			DESIGN.action(canvas, "키보드 조작 / 돌아가기", go_back)
		var close_art := DESIGN.shape(canvas, "음료 화면 닫기 / normal")
		if close_art != null:
			DESIGN.action(canvas, "음료 화면 닫기 / normal", close)
		var rows: Array = (
			[["골드 생산량", "production"], ["생산 주기", "cycle"], ["물품 개수", "items"]]
			if page == "auto_upgrade"
			else [["수집 확률", "chance"], ["수집 개수", "capacity"]]
		)
		for row: Array in rows:
			actions[row[1]] = DESIGN.action(
				canvas, "시설 / %s / 강화 버튼" % row[0], _upgrade.bind(row[1])
			)

	refresh()


func _process(_delta: float) -> void:
	if is_instance_valid(canvas):
		refresh()


func refresh() -> void:
	var data := RULES.state(session)
	if page == "purchase":
		_set_text("Header / Wallet", AMOUNTS.format_gold(session.money))
		for entry in [["Auto", "auto"], ["Trash", "trash"]]:
			var kind: String = entry[1]
			var frame := DESIGN.shape(canvas, "Action / Buy " + entry[0])
			var label: Label = DESIGN.shape(frame, "Label")
			var price: Label = DESIGN.shape(frame, "Price / Value")
			var unlocked: bool = data[kind + "_unlocked"]
			var owned: bool = data[kind + "_owned"]
			var currency := DESIGN.shape(frame, "Price / Currency")
			currency.visible = not owned
			for icon: CanvasItem in currency.get_children():
				icon.visible = not unlocked if icon.name == "UnlockCan" else unlocked
			label.text = "업그레이드" if owned else ("구매" if unlocked else "해금")
			if owned:
				label.position.x = 0
				label.size.x = frame.size.x
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			price.visible = not owned
			price.text = "" if owned else str(
				RULES.CATALOG[kind].price if unlocked else RULES.CATALOG[kind].unlock
			)
			DESIGN.fit_text(price, 44, 16)
			actions[kind].disabled = not owned and (
				session.money < RULES.CATALOG[kind].price if unlocked
				else session.cans < RULES.CATALOG[kind].unlock
			)
		_set_text("Auto / Production / Value", "%d /회" % RULES.production(session))
		_set_text("Auto / Cycle / Value", "%d 초" % int(RULES.cycle(session)))
		_set_text("Auto / Drop / Value", "20 %")
		_set_text(
			"Trash / Chance / Value", "%d %%" % int(round(RULES.collection_chance(session) * 100))
		)
		_set_text("Trash / Count / Value", "%d 개" % RULES.collection_capacity(session))
	elif page.ends_with("upgrade"):
		_set_text("설정 / 도움말", "보유 골드 %s" % AMOUNTS.format_amount(session.money))
		for key: String in actions:
			var button: Button = actions[key]
			var frame: Control = button.get_parent()
			var label: Label = DESIGN.shape(frame, "Label")
			if label == null:
				label = DESIGN.shape(frame, "저장 / normal / 문구")
			var level: int = data[key]
			var title: String = {
				"production": "골드 생산량", "cycle": "생산 주기", "items": "물품 개수",
				"chance": "수집 확률", "capacity": "수집 개수",
			}[key]
			label.text = "%s · 최대 강화" % title if level >= RULES.MAX_LEVEL else (
				"%s · %d 골드" % [title, RULES.upgrade_price(session, key)]
			)
			label.position.x = 14
			label.size.x = 208
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 18)
			button.disabled = (
				level >= RULES.MAX_LEVEL or not data[RULES.UPGRADES[key] + "_owned"]
				or session.money < RULES.upgrade_price(session, key)
			)


func _preview(_kind: String) -> void:
	var gold := DESIGN.shape(canvas, "FX / Produced Gold")
	var item := DESIGN.shape(canvas, "FX / Dropped Item")
	var collected := DESIGN.shape(canvas, "FX / Collected Item")
	if preview_origins.is_empty():
		preview_origins = {"gold": gold.position, "item": item.position, "collected": collected.position}
	if is_instance_valid(preview_tween):
		preview_tween.kill()
	gold.position = preview_origins.gold + Vector2(0, -8)
	item.position = preview_origins.item + Vector2(0, 10)
	collected.position = preview_origins.collected + Vector2(0, 16)
	gold.show()
	gold.modulate.a = 1.0
	item.show()
	item.modulate.a = 1.0
	collected.show()
	collected.modulate.a = 0.7
	preview_tween = create_tween()
	preview_tween.tween_interval(0.24)
	preview_tween.tween_callback(func() -> void:
		gold.position.y = preview_origins.gold.y - 24
		gold.modulate.a = 0.25
		item.modulate.a = 0.0
		collected.position.y = preview_origins.collected.y + 30
		collected.modulate.a = 0.0
	)
	preview_tween.tween_interval(1.4)
	preview_tween.tween_callback(func() -> void:
		gold.modulate.a = 0.0
		item.modulate.a = 0.0
		collected.modulate.a = 0.0
	)


func _set_text(source_name: String, value: String) -> void:
	var label: Label = DESIGN.shape(canvas, source_name)
	if label != null:
		label.text = value


func _purchase(kind: String) -> void:
	var data := RULES.state(session)
	if data[kind + "_owned"]:
		_show_page(kind + "_upgrade")
		return
	var succeeded: bool = (
		session.purchase_facility(kind) if data[kind + "_unlocked"]
		else session.unlock_facility(kind)
	)
	if succeeded:
		changed.emit()
	refresh()


func _upgrade(key: String) -> void:
	if session.upgrade_facility(key):
		changed.emit()
	refresh()


func go_back() -> void:
	if page.ends_with("upgrade"):
		_show_page("purchase")
	else:
		close()


func close() -> void:
	closed.emit()
	if is_instance_valid(previous_focus) and previous_focus.is_visible_in_tree():
		previous_focus.grab_focus()
	queue_free()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		go_back()
		get_viewport().set_input_as_handled()


func _layout() -> void:
	if is_instance_valid(canvas):
		DESIGN.fit(canvas, size)
