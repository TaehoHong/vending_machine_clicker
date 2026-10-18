extends Control

var elapsed: float = 0.0
var target: Vector2
var coin_position: Vector2
var coin_scale := Vector2.ONE
var tilt: float = 0.0
var opacity: float = 0.0
var flash: float = 0.0

func advance(time: float) -> void:
	elapsed = time
	var start := target + Vector2(76, 72)
	if time < 0.18:
		var t := clampf(time / 0.18, 0, 1)
		coin_position = start + Vector2(0, 8 * (1 - t))
		coin_scale = Vector2.ONE * lerpf(0.65, 1.0, sin(t * PI * 0.5))
		tilt = lerpf(-0.3, -0.15, t)
		opacity = t
	elif time < 0.65:
		var t := clampf((time - 0.18) / 0.47, 0, 1)
		var travel := t * t * (3 - 2 * t)
		var control := target + Vector2(60, -34)
		coin_position = (1 - travel) * (1 - travel) * start + 2 * (1 - travel) * travel * control + travel * travel * target
		coin_scale = Vector2(lerpf(1.0, 0.22, travel), lerpf(1.0, 0.72, travel))
		tilt = lerpf(-0.15, 0.0, travel)
		opacity = 1.0
	elif time < 0.8:
		var t := (time - 0.65) / 0.15
		coin_position = target + Vector2(-3 * t, -3 * t)
		coin_scale = Vector2(lerpf(0.22, 0.02, t), lerpf(0.72, 0.36, t))
		tilt = 0
		opacity = 1 - t
	else:
		opacity = 0
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
	var edge := PackedVector2Array([Vector2(-9, -18), Vector2(9, -18), Vector2(15, -12), Vector2(18, -6), Vector2(18, 6), Vector2(15, 12), Vector2(9, 18), Vector2(-9, 18), Vector2(-15, 12), Vector2(-18, 6), Vector2(-18, -6), Vector2(-15, -12)])
	draw_colored_polygon(edge, Color(0.05, 0.07, 0.1, opacity))
	draw_set_transform(coin_position, tilt, coin_scale * 0.88)
	draw_colored_polygon(edge, Color(1.0, 0.73, 0.22, opacity))
	draw_arc(Vector2.ZERO, 14, PI * 0.95, PI * 1.95, 12, Color(1.0, 0.96, 0.65, opacity), 3)
	draw_arc(Vector2.ZERO, 14, -0.05, PI * 0.95, 12, Color(0.63, 0.32, 0.06, opacity), 2)
	draw_arc(Vector2.ZERO, 11, 0, TAU, 16, Color(1.0, 0.85, 0.4, opacity), 1)
	var shine := maxf(0.0, sin(elapsed * 10)) * opacity
	draw_line(Vector2(-10, -10), Vector2(-2, -10), Color(1, 1, 1, shine), 2)
	draw_line(Vector2(-6, -14), Vector2(-6, -6), Color(1, 1, 1, shine), 2)
	draw_set_transform(Vector2.ZERO)
