extends Control

signal changed

const DESIGN = preload("res://src/shared/ui/design_view.gd")
var session: RefCounted
var customer_flow: Node2D
var drops: Dictionary = {}
var _gold_effects: Dictionary[Control, int] = {}

func _ready() -> void:
	customer_flow = preload("res://src/features/facilities/effects/customer_flow.gd").new()
	customer_flow.session = session
	add_child(customer_flow)
	refresh()


func advance(delta: float) -> void:
	var event: Dictionary = session.advance_facilities(delta)
	refresh()
	if event.produced > 0:
		_start_gold_effect(event.produced)
		customer_flow.produced()
	if event.produced > 0 or event.collected > 0 or event.expired > 0:
		changed.emit()


func _start_gold_effect(amount: int) -> void:
	var coin: Control = preload("res://src/shared/ui/icons/gold_icon.tscn").instantiate()
	coin.name = "FacilityGoldEffect"
	coin.position = Vector2(832, 404)
	coin.scale = Vector2.ONE * 1.5
	coin.z_index = 20
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(coin)
	_gold_effects[coin] = amount
	var motion := coin.create_tween()
	if get_node("/root/Preferences").values.reduce_motion:
		motion.tween_property(coin, "modulate:a", 0.0, 0.15)
	else:
		motion.tween_property(coin, "position:y", 372.0, 0.22).set_trans(
			Tween.TRANS_QUAD
		).set_ease(Tween.EASE_OUT)
		motion.tween_property(coin, "position:y", 404.0, 0.28).set_trans(
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
			item.position = Vector2(908 + (id % 3) * 10, 432)
			item.size = Vector2(28, 39)
			item.z_index = 20
			item.icon = preload("res://src/shared/ui/icons/can_icon.svg")
			item.expand_icon = true
			for state in ["normal", "hover", "pressed", "focus"]:
				item.add_theme_stylebox_override(state, StyleBoxEmpty.new())
			add_child(item)
			item.pressed.connect(
				func() -> void:
					if session.collect_facility_item(id) > 0:
						changed.emit()
			)
			drops[id] = item
		var item: Button = drops[id]
		item.tooltip_text = "빈캔 %d개 · %.1f초 후 소멸" % [drop.amount, drop.remaining]
		item.modulate.a = 0.45 if drop.remaining < 3 and fmod(drop.remaining, 0.5) < 0.25 else 1.0
	for id: int in drops.keys():
		if not live.has(id):
			drops[id].queue_free()
			drops.erase(id)
