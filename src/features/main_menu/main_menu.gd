extends Control

signal start_game_requested(is_new_game: bool)
signal exit_requested

const DESIGN = preload("res://src/shared/ui/design_view.gd")
var load_button: Button
var new_game_button: Button
var menu_status: Label
var save_summary: Label
var settings: Control
var _new_game_position: Vector2
var _load_position: Vector2
var _hidden_menu_parts: Array[CanvasItem] = []


func _ready() -> void:
	new_game_button = DESIGN.action($Design, "새 게임 / normal", _on_new_game_button_pressed)
	load_button = DESIGN.action($Design, "이어하기 / disabled", _on_load_game_button_pressed)
	DESIGN.action($Design, "종료 / normal", _on_exit_button_pressed)
	DESIGN.action($Design, "설정 / normal", _open_settings)
	save_summary = DESIGN.shape($Design, "MenuBox / SaveSummary / 저장된 게임이 없습니다.")
	menu_status = DESIGN.shape(
		$Design, "MenuBox / Status / 기존 저장을 백업하지 못했습니다. 다시 시도해주세요."
	)
	_new_game_position = new_game_button.get_parent().position
	_load_position = load_button.get_parent().position
	resized.connect(_layout)
	_layout()
	new_game_button.grab_focus()


func _layout() -> void:
	DESIGN.fit($Design, size)


func update_save_status(available: bool, summary: String) -> void:
	load_button.disabled = not available
	load_button.tooltip_text = "저장된 게임을 이어서 시작합니다." if available else "저장된 게임이 없습니다."
	save_summary.text = summary if available else "저장된 게임이 없습니다."
	new_game_button.get_parent().position = _load_position if available else _new_game_position
	load_button.get_parent().position = _new_game_position if available else _load_position
	DESIGN.shape(new_game_button.get_parent(), "Label").text = "새 게임"
	menu_status.hide()
	var frame := DESIGN.shape($Design, "이어하기 / disabled")
	var label: Label = DESIGN.shape(frame, "이어하기 / disabled / 문구")
	label.add_theme_color_override(
		"font_color", load_button.get_theme_color(
			"font_color" if available else "font_disabled_color"
		)
	)


func show_backup_failure() -> void:
	menu_status.show()
	DESIGN.shape(new_game_button.get_parent(), "Label").text = "다시 시도"


func _open_settings() -> void:
	if not is_instance_valid(settings):
		settings = preload("res://src/features/settings/settings_screen.tscn").instantiate()
		add_child(settings)
		settings.closed.connect(_restore_menu)
	var parts: Array[CanvasItem] = [
		DESIGN.shape($Design, "World / 배경 / 화면 음영"),
		DESIGN.shape($Design, "MenuBox"),
		DESIGN.shape($Design, "Main / Brand / 夜の路地 / BACKSTREET"),
		DESIGN.shape($Design, "Main / Footer / 拾う。飲む。育てる。"),
		menu_status,
	]
	for part in parts:
		if part.visible:
			_hidden_menu_parts.append(part)
			part.hide()
	settings.open(true)


func _restore_menu() -> void:
	for part in _hidden_menu_parts:
		part.show()
	_hidden_menu_parts.clear()


func _on_new_game_button_pressed() -> void:
	start_game_requested.emit(true)


func _on_load_game_button_pressed() -> void:
	start_game_requested.emit(false)


func _on_exit_button_pressed() -> void:
	exit_requested.emit()
