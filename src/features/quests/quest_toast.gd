extends Control

signal claim_requested(quest_id: String)

const DESIGN = preload("res://src/shared/ui/design_view.gd")
const AMOUNTS = preload("res://src/shared/formatting/amount_format.gd")
const DURATION: float = 20.0

var session: RefCounted
var current_id: String = ""
var remaining: float = 0.0
var seen: Array[String] = []
var pending: Array[String] = []
var claim_button: Button


func _ready() -> void:
	claim_button = DESIGN.action(self, "Action / Claim", _request_claim)
	hide()


func sync() -> void:
	for id: String in session.QUEST_IDS:
		var quest: Dictionary = session.quest_status(id)
		if quest.ready and not seen.has(id):
			seen.append(id)
			pending.append(id)
		if quest.claimed:
			pending.erase(id)
			if current_id == id:
				current_id = ""
				hide()
	if current_id.is_empty() and not pending.is_empty():
		current_id = pending.pop_front()
		remaining = DURATION
		var quest: Dictionary = session.quest_status(current_id)
		DESIGN.shape(self, "Goal / Gold").visible = current_id == "coin"
		DESIGN.shape(self, "Goal / Can").visible = current_id == "can"
		var title: Label = DESIGN.shape(self, "Text / Goal")
		title.text = quest.title
		var kind: Label = DESIGN.shape(self, "Text / Kind")
		kind.text = "퀘스트 달성 · " + quest.kind
		var amount: Label = DESIGN.shape(self, "Reward / Amount")
		amount.text = AMOUNTS.format_amount(quest.reward)
		claim_button.accessibility_name = quest.title + " 보상 받기"
		show()


func advance(delta: float, blocked: bool) -> void:
	sync()
	visible = not blocked and not current_id.is_empty()
	if blocked or current_id.is_empty():
		return
	remaining = maxf(0.0, remaining - delta)
	if remaining == 0.0:
		current_id = ""
		hide()
		sync()


func _request_claim() -> void:
	if not current_id.is_empty():
		claim_requested.emit(current_id)
