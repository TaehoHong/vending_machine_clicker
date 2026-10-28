extends Control

const DESIGN = preload("res://src/shared/ui/design_view.gd")
const ABILITY = preload("res://src/features/play/effects/ability_toast_design.tscn")
const SHORTAGE = preload("res://src/features/play/effects/purchase_feedback_design.tscn")

var title: Label
var effect: Label
var _pending: Array[Dictionary] = []
var animation: Tween

var artwork: Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(514, 72)
	artwork = ABILITY.instantiate()
	add_child(artwork)
	title = DESIGN.shape(artwork, "Text / Title")
	effect = DESIGN.shape(artwork, "Text / Effect")
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hide()

func present(
	drink_name: String, description: String, texture: Texture2D, golden: bool = false
) -> void:
	_pending.append({
		"name": "황금음료 · 오로라 골드" if golden else drink_name + " · 능력 획득",
		"description": description, "texture": texture, "scene": ABILITY,
	})
	if not visible:
		_present_next()


func present_shortage(price: int, missing: int) -> void:
	_pending.append({
		"name": "골드 부족", "description": "%d 골드가 필요해요. (%d 골드 부족)" % [price, missing],
		"texture": null, "scene": SHORTAGE,
	})
	if not visible:
		_present_next()


func _present_next() -> void:
	if _pending.is_empty():
		return
	var next: Dictionary = _pending.pop_front()
	artwork.free()
	artwork = next.scene.instantiate()
	add_child(artwork)
	title = DESIGN.shape(artwork, "Text / Title")
	effect = DESIGN.shape(artwork, "Text / Effect")
	title.text = next.name
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
