extends SceneTree

const SESSION = preload("res://src/game/game_session.gd")
const RULES = preload("res://src/game/automation/facility_rules.gd")
const FLOW = preload("res://src/features/facilities/effects/customer_flow.gd")


func _initialize() -> void:
	call_deferred("run_checks")
	create_timer(20).timeout.connect(func() -> void: quit(1))


func expect_clip(actor: AnimatedSprite2D, variant: int, clip: String) -> void:
	var appearance: String = ["01", "02", "03", "08"][variant]
	assert(actor.animation == StringName(appearance + "_" + clip))
	var texture: AtlasTexture = actor.sprite_frames.get_frame_texture(actor.animation, actor.frame)
	assert(texture.atlas.resource_path.ends_with("customer_" + appearance + "_motion.png"))
	assert(actor.scale == Vector2.ONE and actor.rotation == 0.0)
	assert(actor.offset == Vector2(-16, 0), "Padding must preserve the original floor anchor")


func run_checks() -> void:
	var session := SESSION.new()
	var flow := FLOW.new()
	flow.session = session
	root.add_child(flow)
	flow.set_process(false)
	flow._process(0.0)
	assert(flow.customers.is_empty(), "Customers need an installed machine")
	var state := RULES.state(session)
	state.auto_owned = true
	for variant in range(5):
		state.remaining = 4.72
		flow._process(0.0)
		var actor: AnimatedSprite2D = flow.pending.actor
		expect_clip(actor, variant % 4, "walk")
		state.remaining = 1.8
		flow._process(0.0)
		expect_clip(actor, variant % 4, "side_idle")
		var stopped_position := actor.position
		state.remaining = 1.44
		flow._process(0.0)
		expect_clip(actor, variant % 4, "rear_idle")
		assert(actor.position == stopped_position, "Turning must not slide or squash the body")
		state.remaining = 0.001
		flow._process(0.0)
		expect_clip(actor, variant % 4, "operate")
		assert(actor.frame > 0, "The waiting customer must visibly breathe before production")
		assert(flow.customers.size() == 1, "A production cycle must not spawn twice")
		var frozen_frame := actor.frame
		paused = true
		await process_frame
		assert(actor.frame == frozen_frame, "Animation must use the paused facility clock")
		paused = false
		flow.produced()
		expect_clip(actor, variant % 4, "rear_idle")
		state.remaining = 10.0
		flow._process(0.36)
		expect_clip(actor, variant % 4, "pick_up")
		flow._process(0.72)
		expect_clip(actor, variant % 4, "hold")
		flow._process(0.73)
		expect_clip(actor, variant % 4, "carry_walk")
		flow._process(3.0)
		assert(flow.customers.is_empty(), "Finished customers must leave before the next visit")
		await process_frame
	assert(session.money == 0 and session.cans == 0 and session.drinks == 0)
	# A production event after loading has no arrival; it still creates exactly one departing actor.
	flow.produced()
	assert(flow.customers.size() == 1 and flow.pending.is_empty())
	flow.free()
	await process_frame
	print("Customer four variants, delays, breath, pickup, pause, production and cleanup passed.")
	quit()
