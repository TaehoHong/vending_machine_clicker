extends TextureRect

var progress: float = 0.0
var slit: GradientTexture2D
var spill: GradientTexture2D
const SPREAD: float = 3.0
var displayed_progress: float = 0.0
var fever_active: bool = false

func _ready() -> void:
	var light := GradientTexture2D.new()
	light.width = 512
	light.height = 128
	light.fill = GradientTexture2D.FILL_RADIAL
	light.fill_from = Vector2(0.5, 0.5)
	light.fill_to = Vector2(1.0, 0.5)
	light.gradient = Gradient.new()
	light.gradient.offsets = PackedFloat32Array([0.0, 0.18, 0.55, 1.0])
	light.gradient.colors = PackedColorArray([Color(1, 0.86, 0.5, 0.85), Color(1, 0.72, 0.3, 0.55), Color(1, 0.58, 0.16, 0.2), Color(1, 0.5, 0.1, 0)])
	spill = light
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	slit = GradientTexture2D.new()
	slit.width = 256
	slit.height = 8
	slit.gradient = Gradient.new()
	slit.gradient.offsets = PackedFloat32Array([0.0, 0.2, 0.5, 0.8, 1.0])
	slit.gradient.colors = PackedColorArray([Color(1, 0.83, 0.4, 0), Color(1, 0.88, 0.55, 0.55), Color(1, 0.95, 0.75, 0.9), Color(1, 0.88, 0.55, 0.55), Color(1, 0.83, 0.4, 0)])

func set_progress(value: float) -> void:
	progress = value

func _process(delta: float) -> void:
	var session: RefCounted = get_parent().get("session")
	var active: bool = session.search_fever_remaining > 0 or session.punch_fever_remaining > 0
	if active != fever_active:
		fever_active = active
		queue_redraw()
	if not is_equal_approx(displayed_progress, progress):
		displayed_progress = lerpf(displayed_progress, progress, 1.0 - exp(-12.0 * delta))
		queue_redraw()

func _draw() -> void:
	if fever_active:
		return
	# 광원은 본체 아래 안쪽에 고정하고, 클릭할수록 빛의 범위를 넓힌다.
	var source := size * Vector2(0.5, 0.12)
	if spill:
		var spread_size := size * SPREAD * lerpf(0.3, 1.0, sqrt(displayed_progress))
		draw_texture_rect(spill, Rect2(source - spread_size * 0.5, spread_size), false)
	if slit:
		draw_texture_rect(slit, Rect2(size.x * 0.15, source.y - 2, size.x * 0.7, 5), false)
