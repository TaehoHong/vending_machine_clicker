extends Node2D

const RIG = preload("res://src/features/facilities/effects/customer_rig.gd")
const RULES = preload("res://src/game/automation/facility_rules.gd")
var session: RefCounted
var customers: Array[Dictionary] = []
var pending: Dictionary = {}
var next_variant: int = 1
var spawned_for_cycle: bool = false


func _process(delta: float) -> void:
	if session == null:
		return
	var state := RULES.state(session)
	if not state.auto_owned:
		return
	if state.remaining > 4.0:
		spawned_for_cycle = false
	if state.remaining <= 4.0 and not spawned_for_cycle:
		_spawn()
		spawned_for_cycle = true
	for entry: Dictionary in customers.duplicate():
		var actor: Node2D = entry.actor
		if entry.departure < 0:
			_arrive(actor, 4.0 - float(state.remaining))
		else:
			entry.departure += delta
			_depart(actor, entry.departure)
			if entry.departure >= 4.5:
				actor.queue_free()
				customers.erase(entry)


func _spawn() -> void:
	var actor: Node2D = RIG.new()
	add_child(actor)
	actor.configure(next_variant)
	next_variant = next_variant % 4 + 1
	pending = {"actor": actor, "departure": -1.0}
	customers.append(pending)


func produced() -> void:
	if pending.is_empty():
		_spawn()
	pending.actor.set_view(3)
	pending.actor.position = Vector2(774, 261)
	pending.departure = 0.0
	pending = {}


func _arrive(actor: Node2D, elapsed: float) -> void:
	if elapsed < 2.8:
		actor.set_view(1)
		actor.position = Vector2(lerpf(-192, 714, clampf(elapsed / 2.8, 0, 1)), 247)
		actor.walk(elapsed)
	elif elapsed < 3.3:
		var turn := clampf((elapsed - 2.8) / 0.5, 0, 1)
		actor.set_view(1 if turn < 0.5 else 3)
		actor.position = Vector2(lerpf(714, 774, turn), lerpf(247, 261, turn))
		actor.scale.x = absf(turn * 2.0 - 1.0) * 0.8 + 0.2
		actor.position.x += 96.0 * (1.0 - actor.scale.x)
	else:
		actor.set_view(3)
		actor.scale = Vector2.ONE
		actor.position = Vector2(774, 261)
		actor.use_machine(smoothstep(3.3, 4.0, elapsed), 0.0)


func _depart(actor: Node2D, elapsed: float) -> void:
	actor.scale = Vector2.ONE
	if elapsed < 0.2:
		actor.use_machine(1.0, 0.0)
	elif elapsed < 1.0:
		var reach := smoothstep(0.2, 1.0, elapsed)
		actor.use_machine(1.0 - reach, reach)
	elif elapsed < 1.8:
		actor.carrying = true
		actor.use_machine(0.0, 1.0 - smoothstep(1.0, 1.8, elapsed))
	else:
		actor.set_view(1)
		actor.carrying = true
		actor.position.x = lerpf(774, 1190, smoothstep(1.8, 4.5, elapsed))
		actor.walk(elapsed)
