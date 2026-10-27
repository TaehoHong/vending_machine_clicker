extends Control

var remaining: float = 0.0
var duration: float = 5.0
var elapsed: float = 0.0
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
	hits.append({"position": point, "age": 0.0, "seed": randf() * TAU})
	if hits.size() > 12:
		hits.pop_front()
	queue_redraw()

func _process(delta: float) -> void:
	if not visible:
		return
	elapsed += delta
	for i in range(hits.size() - 1, -1, -1):
		hits[i].age += delta
		if hits[i].age >= 0.48:
			hits.remove_at(i)
	queue_redraw()

func _draw() -> void:
	if remaining <= 0:
		return
	# 주먹 잔상 없이 붉은 충격파와 방사형 타격선만 표시한다.
	for hit in hits:
		var t: float = hit.age / 0.48
		var alpha: float = 1.0 - t
		var center: Vector2 = hit.position
		var radius := lerpf(20, 170, t)
		for ring in range(2):
			var points := PackedVector2Array()
			for j in range(33):
				var angle := TAU * j / 32.0
				var jagged := 1.0 if j % 2 == 0 else 0.86
				points.append(center + Vector2(cos(angle), sin(angle)) * radius * jagged * (1 + ring * 0.4))
			draw_polyline(points, Color(1, 0.12 + ring * 0.2, 0.03, alpha * 0.8), 7 - ring * 3, false)
		for j in range(16):
			var angle: float = hit.seed + j * TAU / 16
			var direction := Vector2(cos(angle), sin(angle))
			var start := center + direction * lerpf(6, 55, t)
			var end := center + direction * lerpf(55 + (j % 3) * 25, 150 + (j % 3) * 45, t)
			var tangent := Vector2(-direction.y, direction.x) * 9 * alpha
			draw_colored_polygon(PackedVector2Array([start - tangent, end, start + tangent]), Color(1, 0.08, 0.02, alpha * 0.9))
			draw_line(start, end, Color(1, 0.72, 0.3, alpha), 4, false)
			if j % 2 == 0:
				draw_line(start, start.lerp(end, 0.6), Color(1, 1, 0.82, alpha), 3, false)
		if t < 0.35:
			var star := PackedVector2Array()
			for j in range(16):
				var angle := j * TAU / 16
				var length := (64 if j % 2 == 0 else 20) * (1 - t)
				star.append(center + Vector2(cos(angle), sin(angle)) * length)
			draw_colored_polygon(star, Color(1, 0.1, 0.03, alpha))
			for j in range(star.size()):
				star[j] = center + (star[j] - center) * 0.72
			draw_colored_polygon(star, Color(1, 1, 0.9, alpha))
		for j in range(18):
			var angle: float = hit.seed + j * 2.39
			var point := center + Vector2(cos(angle), sin(angle)) * (25 + t * (100 + (j % 4) * 32)) + Vector2(0, t * t * 50)
			var side := 3 + j % 3
			draw_rect(Rect2(point.round(), Vector2.ONE * side), Color(1, 0.35 + (j % 3) * 0.25, 0.1, alpha))
		# 화면 가장자리의 속도선은 HUD를 피해 중간 높이에만 표시한다.
		for side in [-1.0, 1.0]:
			for j in range(4):
				var origin := Vector2(0 if side < 0 else size.x, size.y * (0.38 + j * 0.09))
				var direction := (center - origin).normalized()
				draw_line(origin, origin + direction * (80 + j * 18), Color(1, 0.12, 0.03, alpha * 0.6), 5, false)
