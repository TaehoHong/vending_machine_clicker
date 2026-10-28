extends Control

const COIN_TEXTURE = preload("res://assets/penpot/86d07029-2be7-815f-8008-d253f280eb68.png")
var elapsed: float = 0.0
var target: Vector2
var coin_position: Vector2
var coin_scale := Vector2.ONE
var tilt: float = 0.0
var opacity: float = 0.0
var flash: float = 0.0

func advance(time: float) -> void:
	elapsed = time
	var start := target + Vector2(77, 72)
	var middle := target + Vector2(35, -2)
	if time < 0.18:
		var t := clampf(time / 0.18, 0, 1)
		coin_position = start.lerp(middle, t)
		coin_scale = Vector2.ONE.lerp(Vector2(16.0 / 24, 28.0 / 32), t)
		tilt = lerpf(deg_to_rad(-10), deg_to_rad(-4), t)
		opacity = 1.0
	elif time < 0.65:
		var t := clampf((time - 0.18) / 0.47, 0, 1)
		coin_position = middle.lerp(target, t)
		coin_scale = Vector2(16.0 / 24, 28.0 / 32).lerp(Vector2(4.0 / 24, 24.0 / 32), t)
		tilt = lerpf(deg_to_rad(-4), 0.0, t)
		opacity = lerpf(1.0, 0.65, t)
	else:
		coin_position = target
		coin_scale = Vector2(4.0 / 24, 24.0 / 32)
		tilt = 0.0
		opacity = 0.65
	flash = sin(clampf((time - 0.69) / 0.3, 0, 1) * PI)
	queue_redraw()

func _draw() -> void:
	if flash > 0.0:
		var radius := 10 + 7 * flash
		var color := Color(1.0, 0.88, 0.48, flash * 0.9)
		for direction in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
			var p: Vector2 = target + direction * radius
			draw_line(p, p + direction * 3, color, 2)
	if opacity <= 0:
		return
	draw_set_transform(coin_position, tilt, coin_scale)
	draw_texture_rect(COIN_TEXTURE, Rect2(-12, -16, 24, 32), false, Color(1, 1, 1, opacity))
	draw_set_transform(Vector2.ZERO)
