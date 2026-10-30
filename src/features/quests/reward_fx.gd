extends Control

const COIN = preload("res://src/features/play/effects/search_coin.gd")
const DESIGN = preload("res://src/shared/ui/design_view.gd")

var particles: Array[Dictionary] = []
var elapsed: float = 0.0
var destination: Control
var origin := Vector2.ZERO
var reduced: bool = false


func start(from: Vector2, target: Control, amount: int, reduce_motion: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(1152, 648)
	destination = target
	origin = from
	reduced = reduce_motion
	var count := 6 if reduced else clampi(int(sqrt(float(amount)) * 0.5), 24, 42)
	for index in range(count):
		var coin: Control = COIN.new()
		coin.tier = 2
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		coin.size = Vector2(26, 26)
		coin.pivot_offset = coin.size * 0.5
		add_child(coin)
		var lane := float(index) / maxf(1, count - 1)
		particles.append({
			"node": coin, "delay": randf_range(0, 0.24),
			"landing": Vector2(lerpf(140, 1012, lane), randf_range(552, 592)),
			"height": randf_range(40, 110), "bounce": randf_range(18, 46),
			"spin": randf_range(-TAU, TAU),
		})
	_process(0)


func _process(delta: float) -> void:
	if not is_instance_valid(destination):
		queue_free()
		return
	elapsed += delta
	DESIGN.fit(self, get_viewport_rect().size)
	var target := get_global_transform().affine_inverse() * destination.get_global_rect().get_center()
	for particle: Dictionary in particles:
		var coin: Control = particle.node
		var age: float = elapsed - particle.delay
		coin.visible = age >= 0
		if age < 0:
			continue
		var landing: Vector2 = particle.landing
		var point: Vector2
		var fly: float = 0.0
		if reduced:
			fly = clampf(age / 0.45, 0, 1)
			point = origin.lerp(target, fly)
		elif age < 0.85:
			var t := age / 0.85
			point = origin.lerp(landing, t) + Vector2(0, -4 * particle.height * t * (1 - t))
		elif age < 1.15:
			point = landing - Vector2(0, sin((age - 0.85) / 0.3 * PI) * particle.bounce)
		elif age < 1.65:
			point = landing
		else:
			fly = clampf((age - 1.65) / 0.75, 0, 1)
			var t := fly * fly
			point = landing.lerp(target, t) - Vector2(0, sin(t * PI) * 130)
		coin.position = point - coin.size * 0.5
		coin.rotation = 0.0 if reduced else particle.spin * minf(age, 1.15)
		coin.scale = Vector2.ONE * lerpf(1.2, 0.15, fly)
		coin.visible = coin.visible and fly < 1.0
	if elapsed >= (0.75 if reduced else 2.7):
		queue_free()
