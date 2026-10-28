extends Control

const RING = preload("res://assets/penpot/search_fever_ring.svg")
const GLOW = preload("res://assets/penpot/8af72ccb-2daf-802c-8008-d253ac9a1a6a.png")
const REWARD_GLOW = preload("res://assets/penpot/86d07029-2be7-815f-8008-d253b2949b3d.png")
const SHARED_GLOW = preload("res://assets/penpot/8af72ccb-2daf-802c-8008-d253cccf8bf0.png")
var remaining: float = 0.0
var duration: float = 10.0
var hud: Control
var simultaneous: bool = false
var title: Label
var timer: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud = preload("res://src/features/play/effects/search_hud.tscn").instantiate()
	add_child(hud)
	var design := preload("res://src/shared/ui/design_view.gd")
	title = design.shape(hud, "Title")
	timer = design.shape(hud, "Timer")
	hide()

func update_state(seconds: float, total: float, blocked: bool) -> void:
	remaining = seconds
	duration = total
	visible = seconds > 0 and not blocked
	var factor := minf(size.x / 1152.0, size.y / 648.0)
	var origin := (size - Vector2(1152, 648) * factor) * 0.5
	hud.position = origin + Vector2(426, 8) * factor
	hud.visible = not simultaneous
	hud.scale = Vector2.ONE * factor
	timer.text = "%.1f초" % maxf(0, remaining)
	var fill: Control = preload("res://src/shared/ui/design_view.gd").shape(hud, "Progress / fill")
	fill.size.x = 176.0 * clampf(remaining / maxf(duration, 0.01), 0, 1)
	queue_redraw()

func _process(_delta: float) -> void:
	if not visible:
		return
	queue_redraw()

func _draw() -> void:
	if remaining <= 0:
		return
	var factor := minf(size.x / 1152.0, size.y / 648.0)
	var origin := (size - Vector2(1152, 648) * factor) * 0.5
	var reward_active := not get_tree().get_nodes_in_group("search_coin_effects").is_empty()
	var glow: Texture2D = SHARED_GLOW if simultaneous else (REWARD_GLOW if reward_active else GLOW)
	var glow_rect := Rect2(470, 432, 211, 54) if simultaneous else (
		Rect2(400, 415, 351, 89) if reward_active else Rect2(427, 422, 297, 75)
	)
	draw_texture_rect(
		glow, Rect2(origin + glow_rect.position * factor, glow_rect.size * factor), false
	)
	if not simultaneous:
		var ring_rect := Rect2(origin + Vector2(9, 435) * factor, Vector2(1133, 203) * factor)
		draw_texture_rect(RING, ring_rect, false, Color(1, 1, 1, 0.7 if reward_active else 1.0))
