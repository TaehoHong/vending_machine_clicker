extends Control

var outlet := Vector2.ZERO
var destination := Vector2.ZERO
var art: TextureRect
var elapsed: float = 0.0
var center := Vector2.ZERO
var trail: PackedVector2Array = []
var tint := Color.WHITE

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	art = TextureRect.new()
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.size = Vector2(64, 82)
	art.pivot_offset = art.size * 0.5
	add_child(art)
	hide()

func begin(texture: Texture2D, color: Color) -> void:
	art.texture = texture
	tint = color
	trail.clear()
	show()
	advance(0)

func advance(time: float) -> void:
	elapsed = time
	var launch := outlet + Vector2(0, 24)
	var scale_value: float = 1.0
	var alpha: float = 1.0
	if time < 0.28:
		var t := clampf(time / 0.28, 0, 1)
		center = outlet.lerp(launch, t)
		scale_value = lerpf(0.18, 0.9, sin(t * PI * 0.5))
		art.rotation = PI * 0.5
	elif time < 0.48:
		var t := (time - 0.28) / 0.2
		center = launch + Vector2(0, -sin(t * PI) * 9)
		scale_value = 0.9
		art.rotation = PI * 0.5 + sin(t * TAU) * 0.06
	else:
		var t := clampf((time - 0.48) / 0.84, 0, 1)
		center = launch.lerp(destination, t) + Vector2(0, -sin(t * PI) * 185)
		scale_value = lerpf(0.95, 0.24, pow(t, 3))
		art.rotation = PI * 0.5 - TAU * t
		alpha = 1.0 - smoothstep(0.85, 1.0, t)
		if t < 0.92:
			trail.append(center)
			if trail.size() > 8:
				trail.remove_at(0)
	art.position = center - art.size * 0.5
	art.scale = Vector2.ONE * scale_value
	art.modulate.a = alpha
	queue_redraw()

func _draw() -> void:
	if elapsed < 0.48:
		draw_set_transform(outlet + Vector2(0, 37), 0, Vector2(1, 0.2))
		draw_circle(Vector2.ZERO, 27, Color(0.02, 0.02, 0.04, 0.5))
		draw_set_transform(Vector2.ZERO)
	for i in range(trail.size()):
		var strength := float(i + 1) / trail.size()
		var side := 2 + strength * 4
		draw_rect(Rect2(trail[i] - Vector2.ONE * side * 0.5, Vector2.ONE * side), Color(tint, strength * 0.5 * art.modulate.a))
