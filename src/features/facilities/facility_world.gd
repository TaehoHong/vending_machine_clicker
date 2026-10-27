extends Control

signal changed
signal management_requested(page: String)

const DESIGN = preload("res://src/shared/ui/design_view.gd")
var session: RefCounted
var customer_flow: Node2D
var gold: Button
var drops: Dictionary = {}

func _ready() -> void:
	DESIGN.action(
		self, "시설 / 자동 자판기 / 설치 · 02 인스턴스", management_requested.emit.bind("auto")
	)
	DESIGN.action(
		self, "시설 / 쓰레기통 / 설치 · 02 인스턴스", management_requested.emit.bind("trash")
	)
	customer_flow = preload("res://src/features/facilities/effects/customer_flow.gd").new()
	customer_flow.session = session
	add_child(customer_flow)
	gold = Button.new()
	gold.position = Vector2(832, 404)
	gold.size = Vector2(36, 36)
	gold.z_index = 20
	var gold_art: Control = preload("res://src/shared/ui/icons/gold_icon.tscn").instantiate()
	gold_art.scale = Vector2(1.5, 1.5)
	gold.add_child(gold_art)
	gold.expand_icon = true
	for state in ["normal", "hover", "pressed", "focus"]:
		gold.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	add_child(gold)
	gold.pressed.connect(
		func() -> void:
			if session.collect_facility_gold() > 0:
				changed.emit()
	)
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
	gold.visible = data.gold > 0
	gold.tooltip_text = "%d Gold 수령" % data.gold
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
