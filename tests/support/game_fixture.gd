extends RefCounted

const PLAY = preload("res://src/features/play/play.tscn")
const PLAY_SCRIPT = preload("res://src/features/play/play.gd")
const SESSION = preload("res://src/game/game_session.gd")
const STORE = preload("res://src/integrations/saves/progress_store.gd")


static func create_game(root: Window, session: RefCounted = null) -> PLAY_SCRIPT:
	var game: PLAY_SCRIPT = PLAY.instantiate()
	game.session = session if session != null else SESSION.new()
	var store: RefCounted = STORE.new("res://.godot/fixture_%d.cfg" % Time.get_ticks_usec())
	game.set_meta("test_store", store)
	game.save_requested.connect(func() -> void: game.last_save_error = store.write(game.session))
	root.add_child(game)
	return game


static func store_for(game: Control) -> RefCounted:
	return game.get_meta("test_store")
