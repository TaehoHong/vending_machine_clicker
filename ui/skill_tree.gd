extends Control

signal unlock_requested(drink_index: int)
signal close_requested
const DATA = preload("res://ui/drink_catalog.gd").DATA
const ORDER: Array[int] = [2, 9, 4, 10, 11, 8, 12, 5, 3, 13, 6, 14, 7]
const DESIGN_SIZE = Vector2(1600, 900)
const MACHINE_POS = Vector2(456, -80)
const MACHINE_SCALE = 688.0 / 1024.0
const FONT = preload("res://ui/fonts/DoHyeon-Regular.ttf")
var canvas: Control
var balance: Label
var close_button: Button
var buttons: Dictionary = {}
var products: Dictionary = {}
var badges: Dictionary = {}
var locks: Dictionary = {}
var readout: Label
var detail_title: Label
var detail_effect: Label
var detail_status: Label
var selected_index: int = 2
var current_cans: int = 0
var unlocked_indices: Array[int] = []
var counts: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop: TextureRect = get_node("../../../TextureRect").duplicate()
	backdrop.name = "Backdrop"
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(16.0/255,27.0/255,41.0/255,0.53)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas = Control.new()
	canvas.name = "Canvas"
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.size = DESIGN_SIZE
	add_child(canvas)
	var machine := TextureRect.new()
	machine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	machine.texture = preload("res://images/vending_approved_15.png")
	machine.position = MACHINE_POS
	machine.size = Vector2(688, 1032)
	machine.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	machine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(machine)
	_label(canvas, Rect2(44,32,360,50), "음료수 추가", 34, Color.WHITE)
	balance = _label(canvas, Rect2(94,91,280,46), "", 24, Color("ffe8b0"))
	var can := TextureRect.new()
	can.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	can.texture = preload("res://ui/can_icon.svg")
	can.position = Vector2(46,94)
	can.size = Vector2(32,40)
	can.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	can.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(can)
	var hint := _label(canvas, Rect2(44,155,350,90), "추가할 음료를 선택하세요\n해금한 음료는 자판기에서 나옵니다", 21, Color("c3d1dd"))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	close_button = _button(canvas, Rect2(1340,28,220,58), "ESC  돌아가기")
	close_button.pressed.connect(func() -> void: close_requested.emit())
	readout = _label(canvas, Rect2(MACHINE_POS + Vector2(827,642) * MACHINE_SCALE, Vector2(56,30)), "", 20, Color("72ff96"))
	readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(DATA.size()):
		var slot: int = DATA[i].display_slot
		var col := slot % 5
		var row := slot / 5
		var tops := [269.0, 507.0, 766.0]
		var bottoms := [468.0, 721.0, 955.0]
		var lefts := [185.0,302.0,422.0,541.0,660.0]
		var bounds := Rect2(MACHINE_POS + Vector2(lefts[col],tops[row]) * MACHINE_SCALE, Vector2(111,bottoms[row]-tops[row]) * MACHINE_SCALE)
		var product := Button.new()
		product.name = DATA[i].key + "Product"
		product.position = bounds.position
		product.size = bounds.size
		product.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		product.pressed.connect(func() -> void: select_drink(i))
		canvas.add_child(product)
		products[i] = product
		var badge := _label(product, Rect2(0,bounds.size.y-22,bounds.size.x,22), "", 13, Color.WHITE)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badges[i] = badge
		if i >= 2:
			var lock: Control = preload("res://ui/drink_lock.gd").new()
			lock.position = Vector2(bounds.size.x-18,3)
			product.add_child(lock)
			locks[i] = lock
			var unlock := _button(canvas, Rect2(585,721,390,54), "")
			unlock.name = DATA[i].key + "UnlockButton"
			unlock.pressed.connect(func() -> void: unlock_requested.emit(i))
			buttons[i] = unlock
	# 상품 아래의 본체 표시창에 선택 정보와 조건을 모은다.
	var panel := Panel.new()
	panel.position = Vector2(577,578)
	panel.size = Vector2(406,103)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("152733")
	panel_style.border_color = Color("78959f")
	panel_style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel",panel_style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(panel)
	detail_title = _label(panel, Rect2(9,3,388,27), "", 21, Color("ffe8b0"))
	detail_effect = _label(panel, Rect2(9,30,388,42), "", 16, Color.WHITE)
	detail_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_status = _label(panel, Rect2(9,74,388,24), "", 16, Color("a9c1ce"))
	resized.connect(_layout)
	_layout()
	update_state(0,[])

func _layout() -> void:
	if not is_instance_valid(canvas): return
	var factor := minf(size.x / DESIGN_SIZE.x,size.y / DESIGN_SIZE.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - DESIGN_SIZE * factor) * 0.5

func _label(parent: Node, bounds: Rect2, value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = bounds.position
	label.size = bounds.size
	label.text = value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font",FONT)
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.add_theme_color_override("font_outline_color",Color("12121d"))
	label.add_theme_constant_override("outline_size",2)
	parent.add_child(label)
	return label

func _button(parent: Node, bounds: Rect2, value: String) -> Button:
	var button := Button.new()
	button.position = bounds.position
	button.size = bounds.size
	button.text = value
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", FONT)
	button.add_theme_font_size_override("font_size",22)
	for state in ["normal","hover","pressed","disabled","focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("4c98bb") if state == "hover" else Color("28536a")
		if state == "disabled": style.bg_color = Color("26323c")
		style.border_color = Color("12121d")
		style.set_border_width_all(4)
		style.shadow_color = Color(0.02,0.03,0.05,0.7)
		style.shadow_size = 2
		style.shadow_offset = Vector2(3,4)
		button.add_theme_stylebox_override(state,style)
	parent.add_child(button)
	return button

func select_drink(index: int) -> void:
	selected_index = index
	_refresh_selection()

func update_state(cans: int, unlocked: Array[int], collected: Dictionary = {}) -> void:
	current_cans = cans
	unlocked_indices = unlocked.duplicate()
	counts = collected.duplicate()
	balance.text = "보유 빈캔  %d개" % cans
	readout.text = "%d/15" % (2 + unlocked.size())
	_refresh_selection()

func _refresh_selection() -> void:
	for i in products:
		var acquired: bool = i < 2 or unlocked_indices.has(i)
		var parent: int = DATA[i].parent
		var available: bool = parent < 0 or unlocked_indices.has(parent)
		var chosen: bool = selected_index == i
		for state in ["normal","hover","pressed","focus"]:
			var style := StyleBoxFlat.new()
			style.bg_color = Color(0.04,0.07,0.1,0.0 if acquired else (0.18 if available else 0.48))
			style.border_color = Color("8ef6dc") if chosen else (Color("68c8b8") if acquired else Color(0,0,0,0))
			style.set_border_width_all(3 if chosen else 1)
			products[i].add_theme_stylebox_override(state,style)
		badges[i].text = "추가됨" if acquired else ("해금 가능" if available else "잠김")
		badges[i].add_theme_color_override("font_color",Color("99ffe0" if acquired else ("ffe78c" if available else "c1cad2")))
		products[i].tooltip_text = DATA[i].name
		if i >= 2:
			locks[i].visible = not acquired
			locks[i].set("available", available)
			locks[i].queue_redraw()
			var button: Button = buttons[i]
			button.visible = chosen
			button.disabled = acquired or not available or current_cans < DATA[i].cost
			button.text = "자판기에 추가됨" if acquired else ("선행 음료 해금 필요" if not available else "빈캔 %d개로 추가" % DATA[i].cost)
	var data: Dictionary = DATA[selected_index]
	var acquired: bool = selected_index < 2 or unlocked_indices.has(selected_index)
	var parent: int = data.parent
	var available: bool = parent < 0 or unlocked_indices.has(parent)
	detail_title.text = data.name
	detail_title.add_theme_color_override("font_color",Color(data.color))
	detail_effect.text = data.effect
	if acquired:
		detail_status.text = "해금 완료 · 획득 %d개" % int(counts.get(selected_index,0))
	elif not available:
		detail_status.text = "먼저 %s 해금" % DATA[parent].name
	else:
		detail_status.text = "필요 빈캔 %d개 · 보유 %d개" % [data.cost,current_cans]

func get_unlock_button(index: int) -> Button:
	return buttons[index]
