extends SceneTree

const PREFERENCES = preload("res://src/integrations/settings/preferences_store.gd")
const SCREEN = preload("res://src/features/settings/settings_screen.tscn")
const DESIGN = preload("res://src/shared/ui/design_view.gd")


func _initialize() -> void:
	call_deferred("run_checks")
	create_timer(10).timeout.connect(func() -> void: quit(1))


func run_checks() -> void:
	var settings: Node = root.get_node("Preferences")
	var original_path: String = settings.path
	var original_values: Dictionary = settings.values.duplicate()
	settings.path = "res://.godot/settings_%d.cfg" % Time.get_ticks_usec()
	assert(settings.set_preference("master", 0.0) == OK)
	assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")))
	assert(settings.set_preference("effects", 35.0) == OK)
	assert(settings.set_preference("reduce_motion", true) == OK)
	assert(settings.set_preference("locale", "ja") == OK)
	var restored := PREFERENCES.new()
	restored.path = settings.path
	root.add_child(restored)
	assert(restored.values.master == 0.0 and restored.values.effects == 35.0)
	assert(restored.values.reduce_motion and restored.values.locale == "ja")
	restored.free()
	var screen: Control = SCREEN.instantiate()
	root.add_child(screen)
	screen.open(true)
	screen._show_page("display")
	var selected := DESIGN.shape(screen.canvas, "화면 / 흔들림 줄이기 / 켬")
	assert(DESIGN.shape(selected, "Label").text.contains("선택됨"))
	screen._show_page("sound")
	var slider := DESIGN.shape(screen.canvas, "소리 / 효과음 / 슬라이더")
	var input: HSlider
	for child: Node in slider.get_children():
		if child is HSlider:
			input = child
	input.value = 82
	assert(settings.values.effects == 82.0)
	assert(DESIGN.shape(screen.canvas, "소리 / 효과음 / 값").text == "82%")
	screen.go_back()
	assert(screen.page == "base" and screen.visible)
	screen.go_back()
	assert(not screen.visible)
	screen.free()
	DirAccess.remove_absolute(settings.path)
	settings.path = original_path
	settings.values = original_values
	settings._apply()
	print("Settings audio, persistence, selection, slider and back navigation passed.")
	quit()
