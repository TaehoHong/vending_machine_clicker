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
	DESIGN.action(canvas, "Action / Close", close)
	if page == "purchase":
		for entry in [["Auto", "auto"], ["Trash", "trash"]]:
			actions[entry[1]] = DESIGN.action(
				canvas, "Action / Buy " + entry[0], _purchase.bind(entry[1])
			)
			DESIGN.action(canvas, "Preview / " + entry[0], _preview.bind(entry[1]))
	else:
		DESIGN.action(canvas, "Action / Back", go_back)
		var keys: Array = (
			["production", "cycle", "items"] if page == "auto_upgrade"
			else ["chance", "capacity"]
		)
		for key: String in keys:
			actions[key] = DESIGN.action(canvas, "Upgrade / " + key + " / Buy", _upgrade.bind(key))

	refresh()


func _process(_delta: float) -> void:
	if is_instance_valid(canvas):
		refresh()


func refresh() -> void:
	var data := RULES.state(session)
	_set_text("Header / Wallet", AMOUNTS.format_gold(session.money))
	_set_text("Header / Cans", AMOUNTS.format_gold(session.cans))
	DESIGN.fit_text(DESIGN.shape(canvas, "Header / Wallet"), 90, 24, 9)
	DESIGN.fit_text(DESIGN.shape(canvas, "Header / Cans"), 45)
	if page == "purchase":
		for entry in [["Auto", "auto"], ["Trash", "trash"]]:
			var kind: String = entry[1]
			var frame := DESIGN.shape(canvas, "Action / Buy " + entry[0])
			var owned: bool = data[kind + "_owned"]
			var cost: int = RULES.CATALOG[kind].cost
			var label: Label = DESIGN.shape(frame, "Label")
			var price: Label = DESIGN.shape(frame, "Price / Value")
			var currency := DESIGN.shape(frame, "Price / Currency")
			label.visible = owned
			currency.visible = not owned
			price.visible = not owned
			price.text = str(cost)
			_layout_cost(frame, currency, price)
			actions[kind].disabled = not owned and session.cans < cost
			actions[kind].tooltip_text = (
				"%s 강화" % ("자동 자판기" if kind == "auto" else "쓰레기통") if owned
				else "빈캔 %d개로 구매·설치" % cost
			)
			DESIGN.shape(canvas, entry[0] + " / Content").modulate.a = 1.0 if owned else 0.55
			var shortage: Label = DESIGN.shape(canvas, entry[0] + " / Shortage")
			shortage.visible = not owned and session.cans < cost
			shortage.text = "빈캔 %s개 부족" % AMOUNTS.format_amount(cost - session.cans)
		_set_text("Auto / Production / Value", _production_summary())
		_set_text("Auto / Drop / Value", "빈캔 %d개 · 드롭 20%%" % RULES.item_count(session))
		_set_text("Auto / Lifetime / Value", "드롭 후 %d초 동안 수령 가능" % int(RULES.DROP_LIFETIME))
		_set_text("Trash / Summary / Value", "자동 수집 %d%% · 최대 %d개" % [
			int(round(RULES.collection_chance(session) * 100)), RULES.collection_capacity(session),
		])
	else:
		_set_text("Current / Production", _production_summary())
		_set_text("Current / Drop", (
			"빈캔 %d개 · 드롭 20%%" if page == "auto_upgrade" else "현재 자판기 드롭 · 빈캔 %d개"
		) % RULES.item_count(session))
		_set_text(
			"Current / Chance", "수집 확률 %d%%" % int(round(RULES.collection_chance(session) * 100))
		)
		_set_text("Current / Capacity", "최대 %d개 / 드롭" % RULES.collection_capacity(session))
		for key: String in actions:
			_refresh_upgrade(key, data)


func _production_summary() -> String:
	return "%d Gold / %d초" % [RULES.production(session), int(RULES.cycle(session))]


func _refresh_upgrade(key: String, data: Dictionary) -> void:
	var prefix := "Upgrade / " + key + " / "
	var level: int = data[key]
	var maximum: bool = level >= RULES.MAX_LEVEL
	var cost: int = RULES.upgrade_price(session, key)
	var button: Button = actions[key]
	var frame: Control = button.get_parent()
	var price: Label = DESIGN.shape(frame, "Label")
	price.text = AMOUNTS.format_amount(cost)
	_layout_cost(frame, DESIGN.shape(frame, "Price / Currency"), price)
	frame.visible = not maximum
	DESIGN.shape(canvas, prefix + "Max").visible = maximum
	_set_text(prefix + "Level", "%d/%d" % [level, RULES.MAX_LEVEL])
	var current: Label = DESIGN.shape(canvas, prefix + "Current")
	var arrow: Label = DESIGN.shape(canvas, prefix + "Arrow")
	var next: Label = DESIGN.shape(canvas, prefix + "Next")
	var values: Array = []
	match key:
		"production":
			values = [RULES.production(session), RULES.production(session) + 10, " Gold/회"]
		"cycle":
			values = [int(RULES.cycle(session)), int(RULES.cycle(session)) - 1, "초"]
		"items":
			values = [RULES.item_count(session), RULES.item_count(session) + 1, "개"]
		"chance":
			var chance := int(round(RULES.collection_chance(session) * 100))
			values = [chance, chance + 10, "%"]
		"capacity":
			values = [RULES.collection_capacity(session), RULES.collection_capacity(session) + 1, "개"]
	var unit: String = values[2]
	current.text = str(values[0]) + (unit if maximum or key == "chance" else "")
	next.text = str(values[1]) + unit
	arrow.visible = not maximum
	next.visible = not maximum
	arrow.position.x = current.position.x + _text_width(current) + 16.0
	next.position.x = arrow.position.x + _text_width(arrow) + 16.0
	button.disabled = (
		maximum or not data[RULES.UPGRADES[key] + "_owned"] or session.money < cost
	)
	button.tooltip_text = (
		"최대 강화" if maximum else "%s 골드로 강화" % AMOUNTS.format_amount(cost)
	)
	var shortage: Label = DESIGN.shape(canvas, prefix + "Shortage")
	shortage.visible = not maximum and session.money < cost
	shortage.text = "%s Gold 부족" % AMOUNTS.format_amount(cost - session.money)
	if key == "capacity":
		var hint: Label = DESIGN.shape(canvas, prefix + "Hint")
		hint.visible = (
			not maximum and RULES.collection_capacity(session) >= RULES.item_count(session)
		)
		hint.text = "현재 드롭 %d개 · 수집량 증가 없음" % RULES.item_count(session)


func _text_width(label: Label) -> float:
	return label.get_theme_font("font").get_string_size(
		label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")
	).x


func _layout_cost(frame: Control, currency: Control, value: Label) -> void:
	var text_width := _text_width(value) if value.visible else 0.0
	var gap := 8.0 if text_width > 0 else 0.0
	var left := (frame.size.x - currency.size.x - gap - text_width) * 0.5
	currency.position.x = left
	value.position.x = left + currency.size.x + gap
	value.size.x = text_width
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT


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
	var succeeded: bool = session.purchase_facility(kind)
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
