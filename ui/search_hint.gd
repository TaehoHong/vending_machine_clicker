extends Control

const IDLE_SECONDS: float = 60.0
var idle_seconds: float = 0.0
var blocked: bool = false
var showing: bool = true
var elapsed: float = 0.0
var fade: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(380, 66)

func _process(delta: float) -> void:
	visible = not blocked
	if blocked:
		return
	elapsed += delta
	idle_seconds += delta
	if not showing and idle_seconds >= IDLE_SECONDS:
		_set_showing(true)
	if modulate.a > 0.0:
		queue_redraw()

func notify_search_click() -> void:
	idle_seconds = 0.0
	_set_showing(false)

func _set_showing(value: bool) -> void:
	if showing == value:
		return
	showing = value
	if fade and fade.is_valid():
		fade.kill()
	fade = create_tween()
	fade.tween_property(self, "modulate:a", 1.0 if value else 0.0, 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	var bounce := floorf(sin(elapsed * 4.0) * 3.0)
	var points := PackedVector2Array([Vector2(190, 0), Vector2(202, 12), Vector2(195, 12), Vector2(195, 21), Vector2(185, 21), Vector2(185, 12), Vector2(178, 12)])
	for i in range(points.size()):
		points[i].y += bounce
	draw_colored_polygon(points, Color("ffe48c"))
	draw_polyline(points + PackedVector2Array([points[0]]), Color("12121d"), 2)
