extends Control

signal claim_requested(quest_id: String)
signal closed

const DESIGN = preload("res://src/shared/ui/design_view.gd")
const AMOUNTS = preload("res://src/shared/formatting/amount_format.gd")

var session: RefCounted
var actions: Dictionary[String, Button] = {}
var previous_focus: Control
@onready var canvas: Control = $Design


func _ready() -> void:
	resized.connect(_layout)


func open(game_session: RefCounted) -> void:
	session = game_session
	previous_focus = get_viewport().gui_get_focus_owner()
	var close_button := DESIGN.action(canvas, "Action / Close", close)
	close_button.accessibility_name = "퀘스트 닫기"
	for id: String in session.QUEST_IDS:
		var row := DESIGN.shape(canvas, "Quest / " + id.capitalize())
		actions[id] = DESIGN.action(row, "Action / Claim", claim_requested.emit.bind(id))
		actions[id].accessibility_name = session.quest_status(id).title + " 보상 받기"
	refresh()
	_layout()
	close_button.grab_focus()


func _process(_delta: float) -> void:
	if session != null:
		refresh()


func refresh() -> void:
	var ready_count: int = 0
	for id: String in session.QUEST_IDS:
		var quest: Dictionary = session.quest_status(id)
		var row := DESIGN.shape(canvas, "Quest / " + id.capitalize())
		var title: Label = DESIGN.shape(row, "Text / Goal")
		title.text = quest.title
		var count: Label = DESIGN.shape(row, "Text / Count")
		count.text = "%d / %d" % [quest.progress, quest.target]
		DESIGN.shape(row, "Progress / Fill").size.x = 352.0 * quest.progress / quest.target
		var claim := DESIGN.shape(row, "Action / Claim")
		var reward := DESIGN.shape(row, "Reward / Static")
		claim.visible = quest.ready
		reward.visible = not quest.ready
		actions[id].disabled = not quest.ready
		for group: Control in [claim, reward]:
			var amount: Label = DESIGN.shape(group, "Reward / Amount")
			amount.text = AMOUNTS.format_amount(quest.reward)
		var status: Label = DESIGN.shape(reward, "Label / Status")
		status.text = "수령 완료" if quest.claimed else "진행 중"
		if quest.ready:
			ready_count += 1
	var ready: Label = DESIGN.shape(canvas, "Header / Ready")
	ready.text = "받을 보상 %d개" % ready_count
	ready.visible = ready_count > 0


func close() -> void:
	closed.emit()
	if is_instance_valid(previous_focus) and previous_focus.is_visible_in_tree():
		previous_focus.grab_focus()
	queue_free()


func _layout() -> void:
	var factor := minf(size.x / 1152.0, size.y / 648.0)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - canvas.size * factor) * 0.5
