extends Control

signal unlock_requested(drink_index: int)
signal close_requested
const DATA = preload("res://src/data/drink_catalog.gd").DATA
const ORDER: Array[int] = [2,9,4,10,11,8,12,5,3,13,6,14,7]
const DESIGN_SIZE = Vector2(1200,760)
const MACHINE_POS = Vector2(408,135)
const MACHINE_SIZE = Vector2(384,576)
const MACHINE_SCALE = 384.0 / 1024.0
const PIXEL_BUTTON = preload("res://src/shared/ui/pixel_button.gd")
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
var detail_effect: Label
var detail_status: Label
var detail_count: Label
var buttons: Dictionary = {}
var products: Dictionary = {}
var selected_index: int = -1
var current_cans: int = 0
var unlocked_indices: Array[int] = []
var counts: Dictionary = {}
var cumulative_effects: Dictionary = {}
var applied_counts: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var foreground := get_theme_color("font_color", "Label")
	var secondary := get_theme_color("secondary_color", "Label")
	var accent := get_theme_color("accent_color", "Label")
	var backdrop := TextureRect.new()
	backdrop.name = "Backdrop"
	backdrop.texture = preload("res://assets/alley_arcade_penpot.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.063,0.106,0.161,0.35)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas = Control.new()
	canvas.name = "Canvas"
	canvas.size = DESIGN_SIZE
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	var machine := TextureRect.new()
	machine.name = "Machine"
	machine.texture = preload("res://assets/vending_approved_15.png")
	machine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	machine.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	machine.position = MACHINE_POS
	machine.size = MACHINE_SIZE
	machine.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	machine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(machine)
	_label(canvas,Rect2(30,24,320,50),"음료와 능력",30,foreground)
	var balance_panel := _panel(Rect2(30,86,210,64),"CanBalance")
	var can := TextureRect.new()
	can.texture = preload("res://src/shared/ui/icons/can_icon.svg")
	can.position = Vector2(20,16)
	can.size = Vector2(22,30)
	can.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	can.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	can.mouse_filter = Control.MOUSE_FILTER_IGNORE
	balance_panel.add_child(can)
	balance = _label(balance_panel,Rect2(55,14,135,34),"",22,foreground)
	balance.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	summary_button = _button(canvas,Rect2(894,18,162,72),"능력 요약")
	summary_button.pressed.connect(_toggle_summary)
	close_button = _button(canvas,Rect2(1056,18,126,72),"ESC 닫기")
	close_button.pressed.connect(func() -> void: close_requested.emit())
	for i in DATA.size():
		var slot: int = DATA[i].display_slot
		var col: int = slot % 5
		var row: int = slot / 5
		var tops := [269.0,507.0,766.0]
		var bottoms := [468.0,721.0,955.0]
		var lefts := [185.0,302.0,422.0,541.0,660.0]
		var product := Button.new()
		product.name = DATA[i].key + "Product"
		product.position = MACHINE_POS + Vector2(lefts[col],tops[row]) * MACHINE_SCALE
		product.size = Vector2(111,bottoms[row]-tops[row]) * MACHINE_SCALE
		product.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		product.focus_mode = Control.FOCUS_NONE
		product.pressed.connect(func() -> void: select_drink(i))
		canvas.add_child(product)
		products[i] = product
	detail_panel = _panel(Rect2(862,241,306,278),"DrinkDetail")
	detail_title = _label(detail_panel,Rect2(18,14,222,34),"",24,foreground)
	var dismiss := _button(detail_panel,Rect2(248,6,52,52),"×", &"PixelIconButton")
	dismiss.add_theme_font_size_override("font_size",18)
	dismiss.pressed.connect(dismiss_details)
	detail_count = _label(detail_panel,Rect2(18,53,270,25),"",16,secondary)
	detail_effect = _label(detail_panel,Rect2(18,92,270,77),"",18,foreground)
	detail_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_status = _label(detail_panel,Rect2(18,169,270,36),"",15,secondary)
	detail_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for i in range(2,DATA.size()):
		var unlock := _button(detail_panel,Rect2(18,210,270,56),"", &"ActionButton")
		unlock.name = DATA[i].key + "UnlockButton"
		unlock.icon = preload("res://src/shared/ui/icons/can_icon.svg")
		unlock.expand_icon = true
		unlock.add_theme_constant_override("icon_max_width",18)
		unlock.pressed.connect(func() -> void: unlock_requested.emit(i))
		buttons[i] = unlock
	summary_panel = _panel(Rect2(840,88,328,252),"AbilitySummary")
	_label(summary_panel,Rect2(18,14,290,35),"현재 적용된 능력",23,accent)
	summary_label = _label(summary_panel,Rect2(18,61,290,170),"",18,secondary)
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	resized.connect(_layout)
	_layout()
	update_state(0,[])
	reset_selection()

func _panel(bounds: Rect2, title: String) -> Panel:
	var panel := Panel.new()
	panel.name = title
	panel.position = bounds.position
	panel.size = bounds.size
	panel.add_theme_stylebox_override("panel",PLAY_PANEL)
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	canvas.add_child(panel)
	return panel

func _label(parent: Node, bounds: Rect2, value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = bounds.position
	label.size = bounds.size
	label.text = value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font",FONT)
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.add_theme_color_override(
		"font_outline_color", get_theme_color("font_outline_color", "Label")
	)
	label.add_theme_constant_override("outline_size",2)
	parent.add_child(label)
	return label

func _button(
	parent: Node, bounds: Rect2, value: String, style: StringName = &""
) -> Button:
	var button := PIXEL_BUTTON.new()
	button.position = bounds.position
	button.size = bounds.size
	button.text = value
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font",FONT)
	button.add_theme_font_size_override("font_size",24)
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.theme_type_variation = style
	button.add_theme_constant_override("outline_size",2)
	parent.add_child(button)
	return button

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
	selected_index = index
	summary_panel.hide()
	_refresh_selection()

func update_state(
	cans: int, unlocked: Array[int], collected: Dictionary = {}, summary: String = "",
	effects: Dictionary = {}, enhancements: Dictionary = {}
) -> void:
	current_cans = cans
	unlocked_indices = unlocked.duplicate()
	counts = collected.duplicate()
	cumulative_effects = effects.duplicate()
	applied_counts = enhancements.duplicate()
	balance.text = "빈캔 %d" % cans
	summary_label.text = summary
	_refresh_selection()

func _refresh_selection() -> void:
	for i in products:
		for state in ["normal","hover","pressed","focus"]:
			# Hover never opens or selects an item.
			var style := StyleBoxFlat.new()
			style.bg_color = Color.TRANSPARENT
			style.border_color = Color("67ddea") if selected_index == i else Color.TRANSPARENT
			style.set_border_width_all(2 if selected_index == i else 0)
			products[i].add_theme_stylebox_override(state,style)
	for i in buttons:
		var acquired: bool = unlocked_indices.has(i)
		buttons[i].visible = selected_index == i and not acquired
		buttons[i].disabled = acquired or current_cans < DATA[i].cost
		buttons[i].text = "%d개로 추가" % DATA[i].cost
	detail_panel.visible = selected_index >= 0
	if selected_index < 0: return
	var data: Dictionary = DATA[selected_index]
	var acquired: bool = selected_index < 2 or unlocked_indices.has(selected_index)
	detail_title.text = data.name
	detail_title.add_theme_font_size_override("font_size",20 if data.name.length() > 10 else 24)
	detail_count.text = "미해금"
	if acquired:
		detail_count.text = "획득 %d개 · 강화 %d/%d" % [
			int(counts.get(selected_index, 0)), int(applied_counts.get(selected_index, 0)),
			int(data.max_enhancements),
		]
	detail_effect.text = data.effect
	if acquired:
		detail_status.text = str(cumulative_effects.get(selected_index,"획득한 음료의 능력이 적용됩니다"))
	else:
		detail_status.text = "해금 후 자판기에서 등장"

func get_unlock_button(index: int) -> Button:
	return buttons[index]
