extends ScrollContainer

signal unlock_requested(drink_index: int)
const DATA = preload("res://ui/drink_catalog.gd").DATA
var canvas: Control
var balance: Label
var buttons: Dictionary = {}
var links: Dictionary = {}

func _ready() -> void:
	canvas = Control.new()
	canvas.name = "Canvas"
	canvas.custom_minimum_size = Vector2(484, 790)
	add_child(canvas)
	balance = _label(canvas, Rect2(0,0,484,26), "", 13, Color("f2bd62"))
	balance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var root := _panel("Root", Rect2(150,32,184,30))
	_label(root, Rect2(0,0,184,30), "수집의 시작", 14, Color("f2bd62")).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(2, DATA.size()):
		var pos: Vector2 = _position(i)
		var width: float = 280 if i == 2 else 234
		var panel := _panel(DATA[i].key, Rect2(pos,Vector2(width,128)))
		var art := TextureRect.new()
		art.texture = load(DATA[i].asset)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.position = Vector2(8,8)
		art.size = Vector2(48,70)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(art)
		_label(panel,Rect2(64,8,width-72,28),DATA[i].name,16,Color(DATA[i].color))
		var effect := _label(panel,Rect2(64,38,width-72,44),DATA[i].effect,11,Color("a6b3bf"))
		effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var button := Button.new()
		button.name = "UnlockButton"
		button.position = Vector2(10,88)
		button.size = Vector2(width-20,30)
		button.add_theme_font_size_override("font_size",12)
		button.theme_type_variation = &"PrimaryButton"
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(func(): unlock_requested.emit(i))
		panel.add_child(button)
		buttons[i] = button
		var connection := Line2D.new()
		connection.width = 2.5
		connection.antialiased = true
		connection.default_color = Color("31404d")
		var end := pos + Vector2(width/2,0)
		var parent: int = DATA[i].parent
		var start := Vector2(242,62) if parent < 0 else _position(parent) + Vector2(140 if parent == 2 else 117,128)
		var mid: float = (start.y+end.y)*0.5
		connection.points = PackedVector2Array([start,Vector2(start.x,mid),Vector2(end.x,mid),end])
		canvas.add_child(connection)
		canvas.move_child(connection,0)
		links[i] = connection

func _position(index: int) -> Vector2:
	if index == 2:
		return Vector2(102,86)
	return Vector2(0 if index % 2 == 1 else 250, 258 + ((index-3)/2)*190)

func _panel(node_name: String, bounds: Rect2) -> Panel:
	var panel := Panel.new()
	panel.name = node_name
	panel.position = bounds.position
	panel.size = bounds.size
	canvas.add_child(panel)
	return panel

func _label(parent: Node, bounds: Rect2, text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = bounds.position
	label.size = bounds.size
	label.text = text
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func update_state(cans: int, unlocked: Array[int]) -> void:
	balance.text = "보유 빈캔 %d개 · 아래로 스크롤해 다음 가지 확인" % cans
	for i in buttons:
		var acquired: bool = unlocked.has(i)
		var parent: int = DATA[i].parent
		var available: bool = parent < 0 or unlocked.has(parent)
		var button: Button = buttons[i]
		button.disabled = acquired or not available or cans < DATA[i].cost
		button.text = "해금 완료" if acquired else ("먼저 %s 해금" % DATA[parent].name if not available else "빈캔 %d개로 해금" % DATA[i].cost)
		links[i].default_color = Color("f2bd62") if acquired else Color("6e8293" if available else "31404d")

func get_unlock_button(index: int) -> Button:
	return buttons[index]
