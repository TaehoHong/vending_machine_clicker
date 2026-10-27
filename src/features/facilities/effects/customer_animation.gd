extends AnimatedSprite2D

const FRAMES = preload("res://src/features/facilities/effects/customer_frames.tres")
const APPEARANCES: Array[String] = ["01", "02", "03", "08"]
var variant: int = 0


func _ready() -> void:
	sprite_frames = FRAMES
	centered = false
	offset = Vector2(-16, 0)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	show_clip(&"walk", 0.0)


func show_clip(clip: StringName, elapsed: float) -> void:
	# 시설 시계 하나로 상태와 프레임을 결정해 생산·일시정지와 재생을 맞춘다.
	var name := StringName(APPEARANCES[variant] + "_" + String(clip))
	animation = name
	var step: float = maxf(0.0, elapsed) * sprite_frames.get_animation_speed(name)
	var count: int = sprite_frames.get_frame_count(name)
	var index: int = floori(step)
	if sprite_frames.get_animation_loop(name):
		index %= count
	else:
		index = mini(index, count - 1)
	set_frame_and_progress(index, fposmod(step, 1.0))
