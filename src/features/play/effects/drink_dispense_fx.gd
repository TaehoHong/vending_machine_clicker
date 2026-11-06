extends Control

var outlet := Vector2.ZERO
var destination := Vector2.ZERO
var art: TextureRect
var reveal: Control
var elapsed: float = 0.0
var center := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	reveal = Control.new()
	reveal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(reveal)
	art = TextureRect.new()
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.size = Vector2(64, 82)
	art.pivot_offset = art.size * 0.5
	reveal.add_child(art)
	hide()

func begin(texture: Texture2D) -> void:
	art.texture = texture
	show()
	advance(0)

func advance(time: float) -> void:
	elapsed = time
	var launch := outlet + Vector2(0, 24)
	var scale_value: float = 1.0
	var alpha: float = 1.0
	if time < 0.28:
		var t := clampf(time / 0.28, 0, 1)
		center = (outlet - Vector2(0, 18)).lerp(launch, t)
		scale_value = 0.9
		art.rotation = PI * 0.5
	elif time < 0.48:
		center = launch
		scale_value = 0.9
		art.rotation = PI * 0.5
	else:
		var t := clampf((time - 0.48) / 0.84, 0, 1)
		var progress := smoothstep(0.0, 1.0, t)
		center = launch.lerp(destination, progress) + Vector2(0, -sin(progress * PI) * 70)
		scale_value = lerpf(0.9, 0.24, t * t)
		art.rotation = lerpf(PI * 0.5, 0.0, progress)
		alpha = 1.0 - smoothstep(0.85, 1.0, t)
	# 배출 중에만 입구 위쪽을 가려 원래 크기의 음료가 밖으로 드러나게 한다.
	reveal.position = Vector2(0, outlet.y + 3)
	reveal.size = get_parent().size
	reveal.clip_contents = time < 0.48
	art.position = center - art.size * 0.5 - reveal.position
	art.scale = Vector2.ONE * scale_value
	art.modulate.a = alpha
	queue_redraw()

func _draw() -> void:
	if elapsed < 0.48:
		draw_set_transform(outlet + Vector2(0, 37), 0, Vector2(1, 0.2))
		draw_circle(Vector2.ZERO, 27, Color(0.02, 0.02, 0.04, 0.5))
		draw_set_transform(Vector2.ZERO)
