extends Control

const DESIGN = preload("res://src/shared/ui/design_view.gd")
const SHORTAGE = preload("res://src/features/play/effects/purchase_feedback_design.tscn")

var title: Label
var effect: Label
var _pending: Array[Dictionary] = []
var animation: Tween

var artwork: Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(514, 72)
	artwork = SHORTAGE.instantiate()
	add_child(artwork)
	title = DESIGN.shape(artwork, "Text / Title")
	effect = DESIGN.shape(artwork, "Text / Effect")
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hide()


func present_shortage(price: int, missing: int) -> void:
	_pending.append({
		"name": "골드 부족", "description": "%d 골드가 필요해요. (%d 골드 부족)" % [price, missing],
	})
	if not visible:
		_present_next()


func _present_next() -> void:
	if _pending.is_empty():
		return
	var next: Dictionary = _pending.pop_front()
	title.text = next.name
	effect.text = next.description
	modulate = Color.WHITE
	show()
	queue_redraw()
	animation = create_tween()
	animation.tween_interval(1.0)
	animation.tween_property(self, "modulate:a", 0.0, 0.6)
	animation.tween_callback(hide)
	animation.tween_callback(_present_next)
