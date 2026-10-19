extends Control

const RED = Color("ff3b22")
const GOLD = Color("ffca57")
const INK = Color("12121d")
var remaining: float = 0.0
var duration: float = 5.0
var elapsed: float = 0.0
var hits: Array[Dictionary] = []
var title: Label
var timer: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	title = _label("PUNCH FEVER", 32)
	timer = _label("", 19)
	hide()

func _label(value: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", preload("res://ui/fonts/Cafe24PROUP.ttf"))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", GOLD)
	label.add_theme_color_override("font_outline_color", INK)
	label.add_theme_constant_override("outline_size", 4)
	add_child(label)
	return label

func update_state(seconds: float, total: float, blocked: bool) -> void:
	remaining = seconds
	duration = total
	visible = seconds > 0 and not blocked
	if seconds <= 0:
		hits.clear()
	var left := size.x * 0.5 - 230
	title.position = Vector2(left + 12, 10)
	title.size = Vector2(280, 42)
	timer.position = Vector2(left + 14, 53)
	timer.size = Vector2(352, 26)
	timer.text = "%.1fs                       GOLD x3" % maxf(0, seconds)
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
	var left := size.x * 0.5 - 230
	draw_rect(Rect2(left - 3, 7, 388, 82), RED)
	draw_rect(Rect2(left, 10, 382, 76), INK)
	draw_rect(Rect2(left + 12, 49, 354, 3), Color("6e251a"))
	draw_rect(Rect2(left + 12, 49, 354 * clampf(remaining / duration, 0, 1), 3), GOLD)
