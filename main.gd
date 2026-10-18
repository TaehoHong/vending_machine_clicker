extends Control

var save_path: String = "user://progress.cfg"
var starting_game: bool = false
var last_backup_path: String = ""
@onready var load_button: Button = $MenuBox/LoadGameButton
@onready var menu_status: Label = $MenuBox/Status

func _ready() -> void:
	load_button.disabled = not has_saved_game()
	load_button.tooltip_text = "저장된 게임을 이어서 시작합니다." if not load_button.disabled else "저장된 게임이 없습니다."
	var summary: Label = $MenuBox/SaveSummary
	if load_button.disabled:
		summary.text = "저장된 게임이 없습니다."
	else:
		var save := ConfigFile.new()
		save.load(save_path)
		summary.text = "마지막 저장 · ¥%d / 음료 %d개" % [int(save.get_value("progress", "money", 0)), int(save.get_value("progress", "drinks", 0))]
	$MenuBox/NewGameButton.grab_focus()

func has_saved_game() -> bool:
	var save := ConfigFile.new()
	return save.load(save_path) == OK and save.get_value("progress", "money", null) is int

func _on_new_game_button_pressed() -> void:
	_start_game(true)

func _on_load_game_button_pressed() -> void:
	if has_saved_game():
		_start_game(false)

func _backup_existing_save() -> bool:
	if not FileAccess.file_exists(save_path):
		return true
	var backup_dir: String = save_path.get_base_dir().path_join("backups")
	if DirAccess.make_dir_recursive_absolute(backup_dir) != OK:
		return false
	last_backup_path = backup_dir.path_join("progress_%d_%d.cfg" % [int(Time.get_unix_time_from_system()), Time.get_ticks_usec()])
	return DirAccess.copy_absolute(save_path, last_backup_path) == OK

func _start_game(is_new_game: bool) -> void:
	if starting_game:
		return
	if is_new_game and not _backup_existing_save():
		menu_status.text = "기존 저장을 백업하지 못했습니다. 다시 시도해주세요."
		return
	starting_game = true
	var game = load("res://Game.tscn").instantiate()
	game.start_new_game = is_new_game
	game.save_path = save_path
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	queue_free()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
