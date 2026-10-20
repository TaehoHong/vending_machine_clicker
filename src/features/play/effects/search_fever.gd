extends Control

const FONT = preload("res://assets/fonts/Cafe24PROUP.ttf")
const GOLD = Color("ffe476")
const ORANGE = Color("ff8b24")
const INK = Color("12121d")
var remaining: float = 0.0
var duration: float = 10.0
var elapsed: float = 0.0
var source := Vector2.ZERO
var pulses: Array[Dictionary] = []
var coin_trails: Dictionary = {}
var title: Label
var timer: Label
var badge: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	title = _label("SEARCH FEVER", 34, GOLD)
	timer = _label("", 18, Color.WHITE)
	badge = _label("GOLD\nx2", 22, GOLD)
	visible = false

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", INK)
	label.add_theme_constant_override("outline_size", 4)
	add_child(label)
	return label

func update_state(seconds: float, total: float, blocked: bool) -> void:
	remaining = seconds
	duration = total
	visible = seconds > 0 and not blocked
	if seconds <= 0:
		pulses.clear()
		coin_trails.clear()
	var left := size.x * 0.5 - 230.0
	title.position = Vector2(left + 4, 10)
	title.size = Vector2(300, 44)
	timer.position = Vector2(left + 248, 57)
	timer.size = Vector2(54, 24)
	timer.text = "%.1fs" % maxf(0, remaining)
	badge.position = Vector2(left + 316, 15)
	badge.size = Vector2(62, 68)
	queue_redraw()

func add_click(position: Vector2) -> void:
	pulses.append({"position": position, "age": 0.0})
	if pulses.size() > 16:
		pulses.pop_front()

func _process(delta: float) -> void:
	if not visible:
		return
	elapsed += delta
	var live: Dictionary = {}
	for coin in get_tree().get_nodes_in_group("search_coin_effects"):
		var id: int = coin.get_instance_id()
		live[id] = true
		if not coin_trails.has(id):
			coin_trails[id] = PackedVector2Array()
		var path: PackedVector2Array = coin_trails[id]
		var point: Vector2 = coin.get_global_transform() * (coin.size * 0.5)
		if path.is_empty() or path[path.size() - 1].distance_to(point) > 2:
			path.append(point)
			if path.size() > 12:
				path.remove_at(0)
			coin_trails[id] = path
	for id in coin_trails.keys():
		if not live.has(id):
			coin_trails.erase(id)
	for i in range(pulses.size() - 1, -1, -1):
		pulses[i].age += delta
		if pulses[i].age >= 0.48:
			pulses.remove_at(i)
	queue_redraw()

func _draw() -> void:
	if remaining <= 0:
		return
	var pulse := 0.75 + sin(elapsed * 5) * 0.15
	# 원본 C안의 사각 픽셀 궤적을 바닥 원근에 맞춘 낮은 타원으로 배치한다.
	for i in range(30):
		var angle := TAU * float(i) / 30 + elapsed * 0.5
		var point := source + Vector2(cos(angle) * 180, sin(angle) * 33)
		if point.y < source.y - 14 and absf(point.x - source.x) < 110:
			continue
		draw_rect(Rect2(point.round() - Vector2(8, 3), Vector2(16, 6)), Color(1, 0.45, 0.03, 0.38))
		draw_rect(Rect2(point.round() - Vector2(6, 2), Vector2(12, 4)), Color(1, 0.65, 0.1, pulse))
		draw_rect(Rect2(point.round() - Vector2(4, 1), Vector2(8, 2)), GOLD)
	for i in range(16):
		var phase := fmod(elapsed * 0.55 + i * 0.137, 1)
		var x := source.x + sin(i * 2.39) * (90 + phase * 100)
		var y := source.y - 10 - phase * 35
		var alpha := sin(phase * PI) * 0.65
		if y < source.y - 14 and absf(x - source.x) < 110:
			continue
		draw_rect(Rect2(Vector2(x, y).round(), Vector2(5, 5)), Color(1, 0.7, 0.22, alpha))
	for path in coin_trails.values():
		for i in range(0, path.size(), 2):
			var strength: float = float(i + 1) / path.size()
			var side: float = 2 + floorf(strength * 3)
			var point: Vector2 = path[i]
			draw_rect(Rect2(point.round() - Vector2.ONE * side * 0.5, Vector2.ONE * side), Color(1, 0.61, 0.08, strength * 0.9))
	for click in pulses:
		var t: float = click.age / 0.48
		var color := Color(1, 0.63, 0.16, 1 - t)
		for i in range(6):
			var angle := -PI + float(i) * PI / 5
			var direction := Vector2(cos(angle), sin(angle))
			var origin: Vector2 = click.position + direction * lerpf(7, 38, t)
			draw_line(origin, origin + direction * 7, INK * Color(1, 1, 1, 1 - t), 5)
			draw_line(origin, origin + direction * 7, color, 3)
	# 모서리 장식은 HUD 바깥에만 두어 클릭과 읽기를 방해하지 않는다.
	for corner in [Vector2(12, 12), Vector2(size.x - 12, 12), Vector2(12, size.y - 12), size - Vector2(12, 12)]:
		var direction := Vector2(1 if corner.x < size.x * 0.5 else -1, 1 if corner.y < size.y * 0.5 else -1)
		draw_line(corner, corner + Vector2(direction.x * 30, 0), ORANGE, 5)
		draw_line(corner, corner + Vector2(0, direction.y * 30), ORANGE, 5)
		draw_rect(Rect2(corner - Vector2(2, 2), Vector2(4, 4)), GOLD)
	var left := size.x * 0.5 - 230
	draw_rect(Rect2(left, 10, 382, 78), INK)
	draw_rect(Rect2(left, 10, 382, 78), ORANGE, false, 3)
	draw_rect(Rect2(left + 6, 55, 300, 28), INK)
	draw_rect(Rect2(left + 9, 58, 232, 21), Color("39312b"))
	var fill := 232 * clampf(remaining / maxf(duration, 0.01), 0, 1)
	draw_rect(Rect2(left + 9, 58, fill, 21), ORANGE)
	draw_rect(Rect2(left + 9, 58, fill, 4), GOLD)
	for i in range(9):
		var x := left + 16 + fmod(elapsed * 38 + i * 26, maxf(1, fill - 8))
		if fill > 8:
			draw_line(Vector2(x, 75), Vector2(minf(x + 8, left + 9 + fill), 64), Color(1, 0.88, 0.3, 0.6), 2)
	draw_line(Vector2(left + 311, 15), Vector2(left + 311, 83), ORANGE, 2)
