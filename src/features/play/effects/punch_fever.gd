extends Control

const IMPACT = preload("res://assets/penpot/punch_fever_impact.svg")
const SHARED_GLOW = preload("res://assets/penpot/8af72ccb-2daf-802c-8008-d253cccf8bf0.png")
var remaining: float = 0.0
var duration: float = 5.0
var hits: Array[Dictionary] = []
var hud: Control
var title: Label
var timer: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud = preload("res://src/features/play/effects/punch_hud.tscn").instantiate()
	add_child(hud)
	var design := preload("res://src/shared/ui/design_view.gd")
	title = design.shape(hud, "Title")
	timer = design.shape(hud, "Timer")
	hide()

func update_state(seconds: float, total: float, blocked: bool) -> void:
	remaining = seconds
	duration = total
	visible = seconds > 0 and not blocked
	if seconds <= 0:
		hits.clear()
	var factor := minf(size.x / 1152.0, size.y / 648.0)
	var origin := (size - Vector2(1152, 648) * factor) * 0.5
	hud.position = origin + Vector2(426, 8) * factor
	hud.scale = Vector2.ONE * factor
	timer.text = "%.1f초" % maxf(0, remaining)
	var fill: Control = preload("res://src/shared/ui/design_view.gd").shape(hud, "Progress / fill")
	fill.size.x = 176.0 * clampf(remaining / maxf(duration, 0.01), 0, 1)
	queue_redraw()

func add_hit(point: Vector2) -> void:
	hits.append({"position": point, "age": 0.0})
	if hits.size() > 12:
		hits.pop_front()
	queue_redraw()

func _process(delta: float) -> void:
	if not visible:
		return
	for i in range(hits.size() - 1, -1, -1):
		hits[i].age += delta
		if hits[i].age >= 0.48:
			hits.remove_at(i)
	queue_redraw()

func _draw() -> void:
	if remaining <= 0:
		return
	var factor := minf(size.x / 1152.0, size.y / 648.0)
	var origin := (size - Vector2(1152, 648) * factor) * 0.5
	var session: RefCounted = get_parent().get("session")
	if session.search_fever_remaining <= 0 and hits.is_empty():
		var glow_rect := Rect2(origin + Vector2(470, 432) * factor, Vector2(211, 54) * factor)
		draw_texture_rect(SHARED_GLOW, glow_rect, false)
	for hit in hits:
		var alpha: float = 1.0 - hit.age / 0.48
		var position: Vector2 = hit.position - Vector2(584, 174) * factor
		draw_texture_rect(
			IMPACT, Rect2(position, Vector2(1152, 348) * factor), false, Color(1, 1, 1, alpha)
		)
