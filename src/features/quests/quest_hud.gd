extends Control

signal claim_requested(quest_id: String)

const DESIGN = preload("res://src/shared/ui/design_view.gd")

var session: RefCounted
var actions: Dictionary[String, Button] = {}


func setup(game_session: RefCounted) -> void:
	session = game_session
	for id: String in session.QUEST_IDS:
		var row := DESIGN.shape(self, "Quest / " + id.capitalize())
		actions[id] = DESIGN.action(row, "Action / Claim", claim_requested.emit.bind(id))
		actions[id].accessibility_name = session.quest_status(id).title + " 보상 받기"
	refresh()


func refresh() -> void:
	for id: String in session.QUEST_IDS:
		var quest: Dictionary = session.quest_status(id)
		var row := DESIGN.shape(self, "Quest / " + id.capitalize())
		var count: Label = DESIGN.shape(row, "Text / Count")
		count.text = "%d/%d" % [quest.progress, quest.target]
		var claim := DESIGN.shape(row, "Action / Claim")
		claim.visible = quest.ready
		actions[id].disabled = not quest.ready
		var status: Label = DESIGN.shape(row, "Label / Status")
		status.visible = quest.claimed
		status.text = "✓ 완료"
