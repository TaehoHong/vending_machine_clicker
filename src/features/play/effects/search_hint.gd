extends Control

const GLOVE: Texture2D = preload("res://src/shared/ui/icons/search_glove.svg")

var blocked: bool = false
var showing: bool = true
var hovered: bool = false
var elapsed: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	visible = not blocked
	if blocked:
		return
	elapsed += delta
	queue_redraw()


func notify_search_click() -> void:
	showing = false
	queue_redraw()


func _draw() -> void:
	if not showing and not hovered:
		return
	var factor: float = size.x / 276.48
	var tint := get_theme_color("hint_color", "SearchHint")
	tint.a = 0.85 if hovered else 0.5
	var w: float = 14.0 * factor
	var h: float = 9.0 * factor
	var line: float = 2.0 * factor
	for corner in [Vector2.ZERO, Vector2(size.x, 0), Vector2(0, size.y), size]:
		var x: float = corner.x - w if corner.x > 0 else 0.0
		var y: float = corner.y - line if corner.y > 0 else 0.0
		draw_rect(Rect2(x, y, w, line), tint)
		x = corner.x - line if corner.x > 0 else 0.0
		y = corner.y - h if corner.y > 0 else 0.0
		draw_rect(Rect2(x, y, line, h), tint)
	if showing:
		var point: Vector2 = size * Vector2(0.48, 0.07)
		point.y += floorf(sin(elapsed * 4.0) * 3.0) * factor
		draw_texture_rect(GLOVE, Rect2(point, Vector2(32, 36) * factor), false)
