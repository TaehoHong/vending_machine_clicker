extends Control

var title: Label
var effect: Label
var animation: Tween
var accent := Color("ffe475")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(510, 94)
	title = _label(21, Vector2(16, 7), Vector2(478, 30))
	effect = _label(18, Vector2(16, 38), Vector2(478, 48))
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hide()

func _label(font_size: int, origin: Vector2, dimensions: Vector2) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", preload("res://assets/fonts/Cafe24PROUP.ttf"))
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = origin
	label.size = dimensions
	add_child(label)
	return label

func present(drink_name: String, description: String, color: Color) -> void:
	if is_instance_valid(animation):
		animation.kill()
	accent = color
	title.text = drink_name + " · 능력 획득"
	title.add_theme_color_override("font_color", color)
	effect.text = description
	modulate = Color.WHITE
	show()
	queue_redraw()
	animation = create_tween()
	animation.tween_interval(1.0)
	animation.tween_property(self, "modulate:a", 0.0, 0.6)
	animation.tween_callback(hide)

func _draw() -> void:
	draw_rect(Rect2(4, 5, size.x, size.y), Color(0.03, 0.04, 0.07, 0.55))
	draw_rect(Rect2(Vector2.ZERO, size), Color("12121d"))
	draw_rect(Rect2(3, 3, size.x - 6, size.y - 6), Color("243c50"))
	draw_rect(Rect2(0, 0, size.x, 3), accent)
	draw_rect(Rect2(0, 0, 4, size.y), accent)
