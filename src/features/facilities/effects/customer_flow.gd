extends Node2D

const ACTOR = preload("res://src/features/facilities/effects/customer_animation.gd")
const RULES = preload("res://src/game/automation/facility_rules.gd")
const WALK_SPEED: float = 160.0
const LEFT_X: float = -192.0
const RIGHT_X: float = 1190.0
const MACHINE_X: float = 774.0
const ARRIVAL_WAIT: float = 1.92
var session: RefCounted
var customers: Array[Dictionary] = []
var passers: Array[Dictionary] = []
var passer_remaining: float = 1.0
var next_passer_variant: int = 0
var next_passer_direction: int = 1
var pending: Dictionary = {}
var next_variant: int = 0
var next_direction: int = -1


func _process(delta: float) -> void:
	if session == null:
		return
	var state := RULES.state(session)
	if not state.auto_owned:
		return
	_advance_passers(delta)
	var cycle: float = RULES.cycle(session)
	var waiting: int = 0
	for entry: Dictionary in customers:
		if entry.departure < 0:
			waiting += 1
	# 보행이 생산 주기보다 길면 다음 생산의 손님도 미리 출발한다.
	while float(state.remaining) + waiting * cycle <= _arrival_lead(next_direction):
		var entry := _spawn(waiting)
		if waiting == 0:
			pending = entry
		waiting += 1
	for entry: Dictionary in customers.duplicate():
		var actor: AnimatedSprite2D = entry.actor
		if entry.departure < 0:
			var remaining: float = float(state.remaining) + int(entry.cycles_ahead) * cycle
			_arrive(actor, _arrival_lead(entry.direction) - remaining, entry.direction)
		else:
			entry.departure += delta
			_depart(actor, entry.departure, entry.direction)
			if entry.departure >= 1.8 + absf(_exit_x(entry.direction) - MACHINE_X) / WALK_SPEED:
				actor.queue_free()
				customers.erase(entry)


func _spawn(cycles_ahead: int = 0) -> Dictionary:
	var actor := _create_actor(next_variant)
	next_variant = (next_variant + 1) % ACTOR.APPEARANCES.size()
	var entry := {
		"actor": actor, "departure": -1.0, "direction": next_direction,
		"cycles_ahead": cycles_ahead,
	}
	next_direction *= -1
	customers.append(entry)
	return entry


func _exit_x(direction: int) -> float:
	return RIGHT_X if direction > 0 else LEFT_X


func _arrival_lead(direction: int) -> float:
	return absf(_exit_x(-direction) - MACHINE_X) / WALK_SPEED + ARRIVAL_WAIT


func _create_actor(variant: int) -> AnimatedSprite2D:
	var actor := ACTOR.new()
	actor.variant = variant
	add_child(actor)
	return actor


func _advance_passers(delta: float) -> void:
	for entry: Dictionary in passers.duplicate():
		entry.elapsed += delta
		var actor: AnimatedSprite2D = entry.actor
		actor.show_clip(&"walk", entry.elapsed)
		actor.position.x = move_toward(
			_exit_x(-entry.direction), _exit_x(entry.direction), entry.elapsed * WALK_SPEED
		)
		if entry.elapsed >= (RIGHT_X - LEFT_X) / WALK_SPEED:
			actor.queue_free()
			passers.erase(entry)
	passer_remaining -= delta
	if passer_remaining <= 0:
		var actor := _create_actor(next_passer_variant)
		next_passer_variant = (next_passer_variant + 1) % ACTOR.APPEARANCES.size()
		actor.position = Vector2(_exit_x(-next_passer_direction), 261)
		actor.flip_h = next_passer_direction < 0
		actor.z_index = 1
		passers.append({"actor": actor, "elapsed": 0.0, "direction": next_passer_direction})
		next_passer_direction *= -1
		passer_remaining = randf_range(4.5, 7.5)


func reward_origin() -> Vector2:
	if not pending.is_empty():
		var actor: AnimatedSprite2D = pending.actor
		var frame: Texture2D = actor.sprite_frames.get_frame_texture(actor.animation, actor.frame)
		return actor.position + actor.offset + frame.get_size() * Vector2(0.5, 1.0)
	var frame: Texture2D = ACTOR.FRAMES.get_frame_texture(&"01_rear_idle", 0)
	# Existing arrival position and sprite offset also anchor rewards restored from a save.
	return Vector2(774, 261) + Vector2(-16, 0) + frame.get_size() * Vector2(0.5, 1.0)


func produced() -> void:
	if pending.is_empty():
		pending = _spawn()
	pending.actor.position = Vector2(MACHINE_X, 261)
	pending.actor.flip_h = false
	pending.actor.show_clip(&"rear_idle", 0.0)
	pending.departure = 0.0
	pending = {}
	for entry: Dictionary in customers:
		if entry.departure < 0:
			entry.cycles_ahead -= 1
			if entry.cycles_ahead == 0:
				pending = entry


func _arrive(actor: AnimatedSprite2D, elapsed: float, direction: int) -> void:
	var walk_duration := _arrival_lead(direction) - ARRIVAL_WAIT
	actor.flip_h = direction < 0 and elapsed < walk_duration + 0.36
	actor.position = Vector2(
		move_toward(_exit_x(-direction), MACHINE_X, maxf(elapsed, 0) * WALK_SPEED), 261
	)
	if elapsed < walk_duration:
		actor.show_clip(&"walk", elapsed)
	elif elapsed < walk_duration + 0.36:
		actor.show_clip(&"side_idle", 0.0)
	elif elapsed < walk_duration + 0.72:
		actor.show_clip(&"rear_idle", 0.0)
	else:
		actor.show_clip(&"operate", elapsed - walk_duration - 0.72)


func _depart(actor: AnimatedSprite2D, elapsed: float, direction: int) -> void:
	if elapsed < 0.36:
		actor.show_clip(&"rear_idle", 0.0)
	elif elapsed < 1.08:
		actor.show_clip(&"pick_up", 0.0)
	elif elapsed < 1.8:
		actor.show_clip(&"hold", 0.0)
	else:
		actor.flip_h = direction < 0
		actor.show_clip(&"carry_walk", elapsed - 1.8)
		actor.position.x = move_toward(MACHINE_X, _exit_x(direction), (elapsed - 1.8) * WALK_SPEED)
