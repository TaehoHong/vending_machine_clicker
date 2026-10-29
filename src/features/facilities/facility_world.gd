extends Control

signal changed

const COIN = preload("res://src/features/play/effects/search_coin.gd")
const AMOUNTS = preload("res://src/shared/formatting/amount_format.gd")
const DESIGN = preload("res://src/shared/ui/design_view.gd")
var session: RefCounted
var customer_flow: Node2D
var gold: Control
var gold_animation: Tween
var drops: Dictionary = {}

func _ready() -> void:
	customer_flow = preload("res://src/features/facilities/effects/customer_flow.gd").new()
	customer_flow.session = session
	add_child(customer_flow)
	gold = Control.new()
	gold.name = "FacilityGoldFX"
	gold.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(gold)
	gold.hide()
	refresh()


func advance(delta: float) -> void:
	var event: Dictionary = session.advance_facilities(delta)
	refresh()
	if event.produced > 0:
		customer_flow.produced()
	if event.produced > 0 or event.collected > 0 or event.expired > 0:
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
	if data.gold > 0 and gold_animation == null:
		_show_gold_reward(data.gold)
	var live: Array[int] = []
	for drop: Dictionary in data.drops:
		var id: int = drop.id
		live.append(id)
		if not drops.has(id):
			var item := Button.new()
			item.position = Vector2(908 + (id % 3) * 10, 404)
			item.size = Vector2(28, 39)
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
			_animate_can_drop(item)
			drops[id] = item
		var item: Button = drops[id]
		item.tooltip_text = "빈캔 %d개 · %.1f초 후 소멸" % [drop.amount, drop.remaining]
		item.modulate.a = 0.45 if drop.remaining < 3 and fmod(drop.remaining, 0.5) < 0.25 else 1.0
	for id: int in drops.keys():
		if not live.has(id):
			drops[id].queue_free()
			drops.erase(id)


func _animate_can_drop(item: Button) -> void:
	item.pivot_offset = item.size * 0.5
	var floor_y: float = customer_flow.reward_origin().y
	var landing := Vector2(item.position.x - 44, floor_y - item.size.y * 0.5 - item.size.x * 0.5)
	if get_node("/root/Preferences").values.reduce_motion:
		item.position = landing
		item.rotation = -PI * 0.5
		return
	var fall: Tween = item.create_tween()
	fall.tween_property(item, "position:y", landing.y, 0.28).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_IN)
	fall.parallel().tween_property(item, "rotation", -PI / 3, 0.28)
	fall.tween_property(item, "position:y", landing.y - 10, 0.07).set_ease(Tween.EASE_OUT)
	fall.tween_property(item, "position:y", landing.y, 0.09).set_ease(Tween.EASE_IN)
	fall.tween_property(item, "position:x", landing.x, 0.32).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_OUT)
	fall.parallel().tween_property(item, "rotation", -TAU - PI * 0.5, 0.32).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_OUT)


func _show_gold_reward(amount: int) -> void:
	gold.position = customer_flow.reward_origin()
	var origin: Vector2 = gold.position
	gold.modulate = Color.WHITE
	gold.show()
	var counts: Array[int] = COIN.breakdown(amount)
	var index: int = 0
	for tier in range(counts.size()):
		# Old saves can contain very large pending amounts; only visual particles are bounded.
		for _piece in range(mini(counts[tier], 8)):
			var coin: Control = COIN.new()
			coin.tier = tier
			coin.size = Vector2(26, 26)
			coin.position = Vector2((index % 5) * 12 - 24, (index / 5) * -8)
			coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
			gold.add_child(coin)
			index += 1
	var amount_label := Label.new()
	amount_label.text = "+" + AMOUNTS.format_amount(amount)
	amount_label.theme_type_variation = &"AccentLabel"
	amount_label.position = Vector2(-32, -34)
	amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gold.add_child(amount_label)
	var reduced: bool = get_node("/root/Preferences").values.reduce_motion
	gold_animation = create_tween()
	gold_animation.tween_property(
		gold, "position:y", origin.y if reduced else origin.y - 36.0, 0.18
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	gold_animation.tween_property(gold, "modulate:a", 0.0, 0.16)
	gold_animation.tween_callback(_complete_gold_reward)


func _complete_gold_reward() -> void:
	if gold_animation == null:
		return
	gold_animation = null
	gold.hide()
	for child: Node in gold.get_children():
		child.queue_free()
	if session.collect_facility_gold() > 0:
		changed.emit()


func _exit_tree() -> void:
	if gold_animation != null:
		gold_animation.kill()
