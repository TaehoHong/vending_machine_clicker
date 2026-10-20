extends CanvasLayer

signal escape_requested
signal save_requested
signal quit_requested

var previous_focus: Control
@onready var overlay: ColorRect = $Overlay
@onready var status: Label = $Overlay/Card/Margin/Buttons/Status
@onready var resume_button: Button = $Overlay/Card/Margin/Buttons/ResumeButton


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		escape_requested.emit()
		get_viewport().set_input_as_handled()


func set_open(open: bool) -> void:
	if open:
		previous_focus = get_viewport().gui_get_focus_owner()
		status.text = "끝내기를 누르면 저장 후 종료합니다."
	overlay.visible = open
	get_tree().paused = open
	if open:
		resume_button.grab_focus()
	elif is_instance_valid(previous_focus) and previous_focus.is_visible_in_tree():
		previous_focus.grab_focus()


func _on_resume_pressed() -> void:
	set_open(false)


func _on_save_pressed() -> void:
	save_requested.emit()


func _on_quit_pressed() -> void:
	quit_requested.emit()
