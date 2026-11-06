extends Control

signal unlock_requested(drink_index: int)
signal close_requested
const DATA = preload("res://src/data/drink_catalog.gd").DATA
const ORDER: Array[int] = [2,9,4,10,11,8,12,5,3,13,6,14,7]
const DESIGN_SIZE = Vector2(1152,648)
const DESIGN = preload("res://src/shared/ui/design_view.gd")
const FONT = preload("res://assets/fonts/Cafe24PROUP.ttf")
const PLAY_PANEL = preload("res://src/shared/ui/themes/quest_style.tres")
var canvas: Control
var balance: Label
var close_button: Button
var summary_button: Button
var detail_panel: Panel
var summary_panel: Panel
var summary_label: Label
var detail_title: Label
var detail_art: TextureRect
var detail_effect: Label
var detail_rules: Label
var detail_rule_rows: Array[Label] = []
var detail_status: Label
var detail_count: Label
var buttons: Dictionary = {}
var products: Dictionary = {}
var product_artwork: Dictionary[int, Control] = {}
var locked_opacity: Dictionary[int, float] = {}
var slot_states: Dictionary = {}
var unlock_labels: Dictionary = {}
var has_selected_drink: bool = false
var selected_index: int = -1
var current_cans: int = 0
var unlocked_indices: Array[int] = []
var counts: Dictionary = {}
var cumulative_effects: Dictionary = {}
var applied_counts: Dictionary = {}
var recently_unlocked_index: int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	canvas = preload("res://src/features/drinks/drink_design.tscn").instantiate()
	add_child(canvas)
	var design := preload("res://src/shared/ui/design_view.gd")
	var foreground := get_theme_color("font_color", "Label")
	var secondary := get_theme_color("secondary_color", "Label")
	balance = design.shape(canvas, "Label")
	summary_button = design.action(canvas, "능력 요약 / normal", _toggle_summary)
	close_button = design.action(canvas, "음료 화면 닫기 / normal", close_requested.emit)
	for button in [summary_button, close_button]:
		for label in button.get_parent().find_children("*", "Label", true, false):
			label.theme_type_variation = &"MenuBody"
			label.remove_theme_font_override("font")
			label.remove_theme_font_size_override("font_size")
			label.remove_theme_constant_override("outline_size")
	var machine: Control = design.shape(
		canvas, "Clicker / World / Vending / 조작부 확대 · 진열 15종"
	)
	machine.name = "Machine"
	for i in DATA.size():
		var slot: int = DATA[i].display_slot
		slot_states[i] = DESIGN.shape(machine, "진열 상태 / %02d" % (slot + 1))
		var selected: Control = DESIGN.shape(slot_states[i], "State / 선택")
		selected.z_index = 2
		for corner in selected.get_children():
			if corner is Panel:
				var style: StyleBoxFlat = corner.get_theme_stylebox("panel").duplicate()
				style.bg_color = get_theme_color("font_color", "InfoTitle")
				corner.add_theme_stylebox_override("panel", style)
		var prefix := "진열 슬롯 / %d행 %d열" % [slot / 5 + 1, slot % 5 + 1]
		for child: Control in machine.get_children():
			if str(child.get_meta("penpot_name", "")).begins_with(prefix):
				var product := Button.new()
				product.name = DATA[i].key + "Product"
				product.position = child.position
				product.size = child.size
				product.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				product.focus_mode = Control.FOCUS_NONE
				product.pressed.connect(select_drink.bind(i))
				machine.add_child(product)
				products[i] = product
				product_artwork[i] = child
				locked_opacity[i] = child.modulate.a
				break
	detail_panel = _panel(Rect2(680, 160, 400, 430), "DrinkDetail", &"InfoPanel")
	detail_art = TextureRect.new()
	detail_art.name = "DrinkArt"
	detail_art.position = Vector2(24, 20)
	detail_art.size = Vector2(40, 60)
	detail_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	detail_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	detail_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	detail_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_panel.add_child(detail_art)
	detail_title = _label(
		detail_panel, Rect2(76, 22, 246, 36), "", 24, foreground, &"InfoTitle"
	)
	detail_count = _label(
		detail_panel, Rect2(76, 62, 300, 26), "", 16, secondary, &"InfoBody"
	)
	detail_count.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_effect = _label(
		detail_panel, Rect2(24, 110, 352, 60), "", 18, foreground, &"InfoBody"
	)
	detail_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_rules = _label(
		detail_panel, Rect2(24, 174, 352, 130), "", 18, foreground, &"InfoBody"
	)
	detail_rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for row in 4:
		for column in 2:
			var label := _label(
				detail_panel, Rect2(24 + 172 * column, 204 + 26 * row, 180, 26),
				"", 18, foreground, &"InfoBody"
			)
			if column == 1:
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			detail_rule_rows.append(label)
	detail_status = _label(
		detail_panel, Rect2(24, 320, 352, 76), "", 16, secondary, &"InfoBody"
	)
	detail_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var dismiss_art: Control = preload("res://src/features/drinks/detail_close.tscn").instantiate()
	dismiss_art.position = Vector2(330, 4)
	detail_panel.add_child(dismiss_art)
	DESIGN.action(dismiss_art, "음료 상세 닫기 / normal", dismiss_details)
	for i in ORDER:
		var artwork: Control = preload("res://src/features/drinks/unlock_button.tscn").instantiate()
		artwork.position = Vector2(98, 348)
		detail_panel.add_child(artwork)
		var unlock := DESIGN.action(
			artwork, "음료 추가 / normal", func() -> void: unlock_requested.emit(i)
		)
		buttons[i] = unlock
		unlock_labels[i] = DESIGN.shape(artwork, "Label")
	summary_panel = _panel(Rect2(680, 160, 400, 430), "AbilitySummary", &"InfoPanel")
	_label(
		summary_panel, Rect2(24, 22, 352, 36), "현재 적용된 능력", 24,
		foreground, &"InfoTitle"
	)
	summary_label = _label(
		summary_panel, Rect2(24, 78, 352, 328), "", 18, secondary, &"InfoBody"
	)
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	resized.connect(_layout)
	_layout()
	update_state(0, [])
	reset_selection()

func _panel(bounds: Rect2, title: String, style: StringName = &"") -> Panel:
	var panel := Panel.new()
	panel.name = title
	panel.position = bounds.position
	panel.size = bounds.size
	panel.theme_type_variation = style
	if style.is_empty():
		panel.add_theme_stylebox_override("panel", PLAY_PANEL)
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	canvas.add_child(panel)
	return panel

func _label(
	parent: Node, bounds: Rect2, value: String, font_size: int, color: Color,
	style: StringName = &""
) -> Label:
	var label := Label.new()
	label.position = bounds.position
	label.size = bounds.size
	label.text = value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.theme_type_variation = style
	label.add_theme_font_size_override("font_size",font_size)
	if style.is_empty():
		label.add_theme_font_override("font", FONT)
		label.add_theme_color_override("font_color", color)
		label.add_theme_color_override(
			"font_outline_color", get_theme_color("font_outline_color", "Label")
		)
		label.add_theme_constant_override("outline_size", 2)
	parent.add_child(label)
	return label

func _layout() -> void:
	if not is_instance_valid(canvas): return
	var factor := minf(size.x / DESIGN_SIZE.x,size.y / DESIGN_SIZE.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - DESIGN_SIZE * factor) * 0.5

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		reset_selection()

func reset_selection() -> void:
	selected_index = -1
	recently_unlocked_index = -1
	if is_instance_valid(summary_panel): summary_panel.hide()
	_refresh_selection()

func dismiss_details() -> void:
	selected_index = -1
	_refresh_selection()

func _toggle_summary() -> void:
	dismiss_details()
	summary_panel.visible = not summary_panel.visible

func select_drink(index: int) -> void:
	if index < 0 or index >= DATA.size(): return
	if index != selected_index:
		recently_unlocked_index = -1
	has_selected_drink = true
	selected_index = index
	summary_panel.hide()
	_refresh_selection()

func update_state(
	cans: int, unlocked: Array[int], collected: Dictionary = {}, summary: String = "",
	effects: Dictionary = {}, enhancements: Dictionary = {}
) -> void:
	if (
		selected_index >= 0 and unlocked.has(selected_index)
		and not unlocked_indices.has(selected_index)
	):
		recently_unlocked_index = selected_index
	current_cans = cans
	unlocked_indices = unlocked.duplicate()
	counts = collected.duplicate()
	cumulative_effects = effects.duplicate()
	applied_counts = enhancements.duplicate()
	balance.text = "빈캔 %d" % cans
	summary_label.text = summary
	_refresh_selection()

func _refresh_selection() -> void:
	var guide := DESIGN.shape(canvas, "수색 / 픽셀 장갑 / 최초 안내")
	if guide != null:
		guide.visible = not has_selected_drink
	for i in products:
		for state in ["normal", "hover", "pressed", "focus"]:
			products[i].add_theme_stylebox_override(state, StyleBoxEmpty.new())
		var acquired: bool = i < 2 or unlocked_indices.has(i)
		product_artwork[i].modulate.a = (
			1.0 if acquired or selected_index == i else locked_opacity[i]
		)
		var badge: Control = slot_states.get(i)
		if badge != null:
			var locked := DESIGN.shape(badge, "State / 미해금")
			var unlocked := DESIGN.shape(badge, "State / 해금됨")
			locked.visible = not acquired
			unlocked.visible = acquired
			DESIGN.shape(badge, "State / 선택").visible = selected_index == i
	for i in buttons:
		var acquired: bool = unlocked_indices.has(i)
		buttons[i].get_parent().visible = selected_index == i and not acquired
		buttons[i].disabled = acquired or current_cans < DATA[i].cost
		var label: Label = DESIGN.shape(buttons[i].get_parent(), "Label")
		label.text = "%d개로 해금" % DATA[i].cost
		buttons[i].get_parent().modulate.a = 0.55 if buttons[i].disabled else 1.0
	detail_panel.visible = selected_index >= 0
	if selected_index < 0: return
	var data: Dictionary = DATA[selected_index]
	var acquired: bool = selected_index < 2 or unlocked_indices.has(selected_index)
	detail_title.text = data.name
	detail_art.texture = load(data.asset)
	detail_title.add_theme_font_size_override("font_size",20 if data.name.length() > 10 else 24)
	detail_count.text = "미해금"
	if acquired:
		detail_count.text = "획득 %d개 · 강화 %d/%d" % [
			int(counts.get(selected_index, 0)), int(applied_counts.get(selected_index, 0)),
			int(data.max_enhancements),
		]
	detail_count.tooltip_text = detail_count.text
	detail_effect.text = data.description
	var probability_rows: PackedStringArray = (
		str(data.effect).split("\n") if data.has("effect_heading") else PackedStringArray()
	)
	detail_rules.text = str(data.get("effect_heading", data.effect)).replace(" · ", "\n")
	detail_rules.size.y = 26 if data.has("effect_heading") else 130
	detail_rules.add_theme_font_size_override("font_size", 16 if data.has("effect_heading") else 18)
	for index in detail_rule_rows.size():
		var label := detail_rule_rows[index]
		label.visible = index / 2 < probability_rows.size()
		if label.visible:
			label.text = probability_rows[index / 2].rsplit(" ", true, 1)[index % 2]
	if acquired:
		detail_status.size.y = 76
		detail_status.text = str(cumulative_effects.get(selected_index,"획득한 음료의 능력이 적용됩니다"))
	else:
		detail_status.size.y = 26
		detail_status.text = (
			"빈캔이 %d개 부족합니다" % (int(data.cost) - current_cans)
			if current_cans < int(data.cost) else "해금 후 자판기에서 등장"
		)
	if (
		acquired and int(data.max_enhancements) > 1
		and int(applied_counts.get(selected_index, 0)) >= int(data.max_enhancements)
	):
		detail_count.text = "MAX · 최대 강화"
		detail_effect.text = ""
		detail_rules.text = str(cumulative_effects.get(selected_index, "")).replace(
			"\n최대 강화 · 추첨 제외", ""
		)
		for label in detail_rule_rows:
			label.hide()
		detail_status.text = "획득 %d개 · 강화 %d/%d\n능력 유지 · 추첨 제외" % [
			int(counts.get(selected_index, 0)), int(applied_counts.get(selected_index, 0)),
			int(data.max_enhancements),
		]
	elif selected_index == recently_unlocked_index:
		detail_count.text = "해금 완료 · 등장 대상"
		detail_status.text = "이제 구매 결과로 등장합니다"

func get_unlock_button(index: int) -> Button:
	return buttons[index]
