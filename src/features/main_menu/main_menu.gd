extends Control

signal start_game_requested(is_new_game: bool)
signal exit_requested

@onready var load_button: Button = $MenuBox/LoadGameButton
@onready var menu_status: Label = $MenuBox/Status


func _ready() -> void:
	$MenuBox/Accent.color = get_theme_color("accent_color", "Label")
	$MenuBox/NewGameButton.grab_focus()


func update_save_status(available: bool, summary: String) -> void:
	load_button.disabled = not available
	load_button.tooltip_text = "저장된 게임을 이어서 시작합니다." if available else "저장된 게임이 없습니다."
	$MenuBox/SaveSummary.text = summary if available else "저장된 게임이 없습니다."


func _on_new_game_button_pressed() -> void:
	start_game_requested.emit(true)


func _on_load_game_button_pressed() -> void:
	start_game_requested.emit(false)


func _on_exit_button_pressed() -> void:
	exit_requested.emit()
