extends Control

signal changed

const COIN = preload("res://src/features/play/effects/search_coin.gd")
const AMOUNTS = preload("res://src/shared/formatting/amount_format.gd")
const DESIGN = preload("res://src/shared/ui/design_view.gd")
const CAN = preload("res://src/shared/ui/icons/can_icon.svg")
var session: RefCounted
var customer_flow: Node2D
var drops: Dictionary = {}
var _gold_effects: Dictionary[Control, int] = {}
var _can_elapsed: float = 0.0

func _ready() -> void:
	customer_flow = preload("res://src/features/facilities/effects/customer_flow.gd").new()
	customer_flow.session = session
	add_child(customer_flow)
	refresh()


func advance(delta: float) -> void:
	_can_elapsed += delta
	var event: Dictionary = session.advance_facilities(delta)
	refresh()
	if event.produced > 0:
		_start_gold_effect(event.produced)
		customer_flow.produced()
	if event.produced > 0 or event.collected > 0 or event.expired > 0:
		changed.emit()


func _start_gold_effect(amount: int) -> void:
	var coin := Control.new()
	coin.name = "FacilityGoldEffect"
	coin.position = customer_flow.reward_origin()
	var origin: Vector2 = coin.position
	coin.z_index = 20
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(coin)
	var counts: Array[int] = COIN.breakdown(amount)
	var index: int = 0
	for tier in range(counts.size()):
		# Old saves can contain very large pending amounts; only visual particles are bounded.
		for _piece in range(mini(counts[tier], 8)):
			var particle: Control = COIN.new()
			particle.tier = tier
			particle.size = Vector2(26, 26)
			particle.position = Vector2((index % 5) * 12 - 24, (index / 5) * -8)
			particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
			coin.add_child(particle)
			index += 1
	var amount_label := Label.new()
	amount_label.text = "+" + AMOUNTS.format_amount(amount)
	amount_label.theme_type_variation = &"AccentLabel"
	amount_label.position = Vector2(-32, -34)
	amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin.add_child(amount_label)
	_gold_effects[coin] = amount
	var motion := coin.create_tween()
	if get_node("/root/Preferences").values.reduce_motion:
		motion.tween_property(coin, "modulate:a", 0.0, 0.15)
	else:
		motion.tween_property(coin, "position:y", origin.y - 36.0, 0.22).set_trans(
			Tween.TRANS_QUAD
		).set_ease(Tween.EASE_OUT)
		motion.tween_property(coin, "position:y", origin.y, 0.28).set_trans(
			Tween.TRANS_QUAD
		).set_ease(Tween.EASE_IN)
		motion.parallel().tween_property(coin, "modulate:a", 0.0, 0.28)
	motion.tween_callback(_finish_gold_effect.bind(coin))


func _finish_gold_effect(coin: Control) -> void:
	if not _gold_effects.has(coin):
		return
	var amount: int = _gold_effects[coin]
	_gold_effects.erase(coin)
	coin.queue_free()
	if session.collect_facility_gold(amount) > 0:
		changed.emit()


func refresh() -> void:
	var rules := preload("res://src/game/automation/facility_rules.gd")
	var data: Dictionary = rules.state(session)
	DESIGN.fit(self, get_viewport().get_visible_rect().size)
	for node: Node in get_children():
		if not node is Control:
			continue
		var child: Control = node
		var source_name: String = child.get_meta("penpot_name", "")
		if source_name.contains("자동 자판기"):
			child.visible = data.auto_owned
		elif source_name.contains("쓰레기통"):
			child.visible = data.trash_owned
	var live: Array[int] = []
	for drop: Dictionary in data.drops:
		var id: int = drop.id
		live.append(id)
		if not drops.has(id):
			var item := Button.new()
			item.position = Vector2(908 + (id % 3) * 10, 404)
			item.size = Vector2(28, 44)
			item.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			item.set_meta("born_at", _can_elapsed)
			for state in ["normal", "hover", "pressed", "focus"]:
				item.add_theme_stylebox_override(state, StyleBoxEmpty.new())
			add_child(item)
			item.draw.connect(_draw_can.bind(item))
			item.pressed.connect(
				func() -> void:
					if session.collect_facility_item(id) > 0:
						changed.emit()
			)
			_animate_can_drop(item)
			drops[id] = item
		var item: Button = drops[id]
		item.modulate.a = 0.45 if drop.remaining < 3 and fmod(drop.remaining, 0.5) < 0.25 else 1.0
		item.queue_redraw()
	for id: int in drops.keys():
		if not live.has(id):
			drops[id].queue_free()
			drops.erase(id)


func _can_art_size() -> Vector2:
	return CAN.get_size() * (39.0 / CAN.get_height())


func _draw_can(item: Button) -> void:
	var landed: bool = item.get_meta("landed", false)
	var highlighted: bool = landed and (item.is_hovered() or item.has_focus())
	var reduced: bool = get_node("/root/Preferences").values.reduce_motion
	var feedback_scale := 1.0
	if landed and not reduced:
		feedback_scale = 0.94 if item.is_pressed() else (1.08 if highlighted else 1.0)
	var art_size := _can_art_size()
	# 눕힌 캔의 바닥 쪽 가장자리를 고정해 호버 확대에도 접지를 유지한다.
	var center := item.pivot_offset + Vector2((feedback_scale - 1.0) * art_size.x * 0.5, 0)
	var tint := Color(1.18, 1.18, 1.12) if highlighted else Color.WHITE
	if landed and item.is_pressed():
		tint = Color(0.82, 0.87, 0.90)
	item.draw_texture_rect(
		CAN, Rect2(center - art_size * feedback_scale * 0.5, art_size * feedback_scale),
		false, tint
	)
	if not landed or reduced:
		return
	var phase := fmod(_can_elapsed - float(item.get_meta("born_at")) - 0.84, 2.8)
	if phase < 0.0 or phase > 0.5:
		return
	var sparkle := item.get_theme_color("font_color", "AccentLabel")
	sparkle.a = sin(phase / 0.5 * PI)
	for point: Vector2 in [Vector2(28, 8), Vector2(20, 35)]:
		item.draw_rect(Rect2(point - Vector2(1, 3), Vector2(2, 6)), sparkle)
		item.draw_rect(Rect2(point - Vector2(3, 1), Vector2(6, 2)), sparkle)


func _animate_can_drop(item: Button) -> void:
	item.pivot_offset = item.size * 0.5
	var floor_y: float = customer_flow.reward_origin().y
	var start := item.position
	start.y = floor_y - 85.5 - item.pivot_offset.y
	if get_node("/root/Preferences").values.reduce_motion:
		_set_can_drop_pose(0.84, item, start, floor_y)
		return
	var fall: Tween = item.create_tween()
	_set_can_drop_pose(0.0, item, start, floor_y)
	fall.tween_method(_set_can_drop_pose.bind(item, start, floor_y), 0.0, 0.84, 0.84)


func _set_can_drop_pose(time: float, item: Button, start: Vector2, floor_y: float) -> void:
	var x := 0.0
	var angle: float
	var lift := 0.0
	if time < 0.28:
		angle = -18.0 * time / 0.28
	elif time < 0.48:
		var q := (time - 0.28) / 0.20
		x = -24.0 * q
		angle = lerpf(-18.0, -105.0, q)
		lift = 18.0 * sin(PI * q)
	else:
		var phase := mini(int((time - 0.48) / 0.12), 2)
		var q := clampf((time - 0.48 - phase * 0.12) / 0.12, 0.0, 1.0)
		q = 1.0 - pow(1.0 - q, 2)
		x = lerpf([-24.0, -36.0, -42.0][phase], [-36.0, -42.0, -44.0][phase], q)
		angle = lerpf([-105.0, -82.0, -94.0][phase], [-82.0, -94.0, -90.0][phase], q)
	item.rotation = deg_to_rad(angle)
	var settle := clampf((time - 0.72) / 0.12, 0.0, 1.0)
	item.scale = Vector2.ONE * lerpf(1.0, 2.0, settle)
	item.set_meta("landed", time >= 0.84)
	# 버튼 여백 대신 실제 아이콘의 회전된 외곽으로 바닥 높이를 맞춘다.
	var art_size := _can_art_size() * item.scale
	var half_extent := (
		absf(cos(item.rotation)) * art_size.y + absf(sin(item.rotation)) * art_size.x
	) * 0.5
	var center_y := floor_y - half_extent - lift
	if time < 0.28:
		center_y = lerpf(start.y + item.pivot_offset.y, center_y, pow(time / 0.28, 2))
	item.position = Vector2(start.x + x, center_y - item.pivot_offset.y)
