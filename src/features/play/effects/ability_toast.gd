extends Control

var title: Label
var effect: Label
var _pending: Array[Dictionary] = []
var animation: Tween

var artwork: Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(514, 72)
	artwork = preload("res://src/features/play/effects/ability_toast_design.tscn").instantiate()
	add_child(artwork)
	var design := preload("res://src/shared/ui/design_view.gd")
	title = design.shape(artwork, "Text / Title")
	effect = design.shape(artwork, "Text / Effect")
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hide()

func present(
	drink_name: String, description: String, color: Color, texture: Texture2D = null
) -> void:
	_pending.append({
		"name": drink_name, "description": description, "color": color, "texture": texture,
	})
	if not visible:
		_present_next()


func _present_next() -> void:
	if _pending.is_empty():
		return
	var next: Dictionary = _pending.pop_front()
	var color: Color = next.color
	title.text = next.name + " · 능력 획득"
	title.add_theme_color_override("font_color", color)
	effect.text = next.description
	if next.texture != null:
		for icon: TextureRect in artwork.find_children("*", "TextureRect", true, false):
			icon.texture = next.texture
	modulate = Color.WHITE
	show()
	queue_redraw()
	animation = create_tween()
	animation.tween_interval(1.0)
	animation.tween_property(self, "modulate:a", 0.0, 0.6)
	animation.tween_callback(hide)
	animation.tween_callback(_present_next)
