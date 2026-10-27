extends Node2D

const ACTOR = preload("res://src/features/facilities/effects/customer_animation.gd")
const RULES = preload("res://src/game/automation/facility_rules.gd")
const ARRIVAL_LEAD: float = 4.72
const DEPARTURE_END: float = 4.8
var session: RefCounted
var customers: Array[Dictionary] = []
var pending: Dictionary = {}
var next_variant: int = 0
var spawned_for_cycle: bool = false


func _process(delta: float) -> void:
	if session == null:
		return
	var state := RULES.state(session)
	if not state.auto_owned:
		return
	if state.remaining > ARRIVAL_LEAD:
		spawned_for_cycle = false
	if state.remaining <= ARRIVAL_LEAD and not spawned_for_cycle:
		_spawn()
		spawned_for_cycle = true
	for entry: Dictionary in customers.duplicate():
		var actor: Node2D = entry.actor
		if entry.departure < 0:
			_arrive(actor, ARRIVAL_LEAD - float(state.remaining))
		else:
			entry.departure += delta
			_depart(actor, entry.departure)
			if entry.departure >= DEPARTURE_END:
				actor.queue_free()
				customers.erase(entry)


func _spawn() -> void:
	var actor := ACTOR.new()
	actor.variant = next_variant
	next_variant = (next_variant + 1) % ACTOR.APPEARANCES.size()
	add_child(actor)
	pending = {"actor": actor, "departure": -1.0}
	customers.append(pending)


func produced() -> void:
	if pending.is_empty():
		_spawn()
	pending.actor.position = Vector2(774, 261)
	pending.actor.show_clip(&"rear_idle", 0.0)
	pending.departure = 0.0
	pending = {}
	spawned_for_cycle = false


func _arrive(actor: Node2D, elapsed: float) -> void:
	if elapsed < 2.8:
		actor.show_clip(&"walk", elapsed)
		actor.position = Vector2(lerpf(-192, 774, clampf(elapsed / 2.8, 0, 1)), 261)
	elif elapsed < 3.16:
		actor.position = Vector2(774, 261)
		actor.show_clip(&"side_idle", 0.0)
	elif elapsed < 3.52:
		actor.show_clip(&"rear_idle", 0.0)
	else:
		actor.show_clip(&"operate", elapsed - 3.52)


func _depart(actor: Node2D, elapsed: float) -> void:
	if elapsed < 0.36:
		actor.show_clip(&"rear_idle", 0.0)
	elif elapsed < 1.08:
		actor.show_clip(&"pick_up", 0.0)
	elif elapsed < 1.8:
		actor.show_clip(&"hold", 0.0)
	else:
		actor.show_clip(&"carry_walk", elapsed - 1.8)
		actor.position.x = lerpf(774, 1190, smoothstep(1.8, DEPARTURE_END, elapsed))
