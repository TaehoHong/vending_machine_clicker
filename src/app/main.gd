extends Control

const MENU = preload("res://src/features/main_menu/main_menu.tscn")
const PLAY = preload("res://src/features/play/play.tscn")
const SESSION = preload("res://src/game/game_session.gd")
const STORE = preload("res://src/integrations/saves/progress_store.gd")

var save_path: String = "user://progress.cfg"
var starting_game: bool = false
var last_backup_path: String = ""
var store: RefCounted
var session: SESSION
var view: Control


func _ready() -> void:
	store = STORE.new(save_path)
	view = MENU.instantiate()
	view.start_game_requested.connect(_start_game)
	view.exit_requested.connect(func() -> void: get_tree().quit())
	add_child(view)
	view.update_save_status(store.exists(), store.summary() if store.exists() else "")


func _start_game(is_new_game: bool) -> void:
	if starting_game or (not is_new_game and not store.exists()):
		return
	if is_new_game and store.has_file():
		last_backup_path = store.backup()
		if last_backup_path.is_empty():
			view.menu_status.text = "기존 저장을 백업하지 못했습니다. 다시 시도해주세요."
			return
	starting_game = true
	session = SESSION.new()
	if not is_new_game:
		store.load_into(session)
	view.queue_free()
	remove_child(view)
	view = PLAY.instantiate()
	view.session = session
	view.save_requested.connect(_save_game)
	view.quit_requested.connect(func() -> void: get_tree().quit())
	add_child(view)
	if is_new_game:
		view._save_progress()


func _save_game() -> void:
	view.last_save_error = store.write(session)
