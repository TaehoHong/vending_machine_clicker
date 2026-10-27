extends CanvasLayer

signal escape_requested
signal save_requested
signal quit_requested

const DESIGN = preload("res://src/shared/ui/design_view.gd")
var previous_focus: Control
var settings: Control
var status: Label
var resume_button: Button
var save_button: Button
var quit_button: Button
@onready var overlay: Control = $Overlay


func _ready() -> void:
	status = DESIGN.shape($Overlay/Design, "저장 상태 / pause")
	resume_button = DESIGN.action($Overlay/Design, "계속 / normal", _on_resume_pressed)
	save_button = DESIGN.action($Overlay/Design, "저장 / normal", _on_save_pressed)
	quit_button = DESIGN.action($Overlay/Design, "끝내기 / normal", _on_quit_pressed)
	DESIGN.action($Overlay/Design, "일시정지 / 설정", _open_settings)
	get_viewport().size_changed.connect(_layout)
	_layout()


func _layout() -> void:
	DESIGN.fit($Overlay/Design, get_viewport().get_visible_rect().size)


func _open_settings() -> void:
	if not is_instance_valid(settings):
		settings = preload("res://src/features/settings/settings_screen.tscn").instantiate()
		$Overlay.add_child(settings)
		settings.closed.connect($Overlay/Design.show)
	$Overlay/Design.hide()
	settings.open(false)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if is_instance_valid(settings) and settings.visible:
			settings.go_back()
		else:
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
