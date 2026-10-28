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
	var window_art := DESIGN.shape(screen.canvas, "화면 / 창 모드 / 선택됨")
	var window_frame := DESIGN.shape(window_art, "Frame")
	assert(window_frame.visible, "The selected native frame is retained without keyboard focus")
	screen._set_preference("fullscreen", true)
	var fullscreen_art := DESIGN.shape(screen.canvas, "화면 / 전체 화면")
	assert(not window_art.get_node("Action").get("selected"))
	assert(fullscreen_art.get_node("Action").get("selected"))
	screen._set_preference("fullscreen", false)
	var selected := DESIGN.shape(screen.canvas, "화면 / 흔들림 줄이기 / 켬")
	assert(DESIGN.shape(selected, "Label").text.contains("선택됨"))
	assert(DESIGN.shape(selected, "Label").text.contains("흔들림 줄이기"))
	screen._show_page("language")
	var japanese := DESIGN.shape(screen.canvas, "언어 / 日本語 / 버튼")
	var korean := DESIGN.shape(screen.canvas, "언어 / 한국어 · 선택됨 / 버튼")
	assert(japanese.get_node("Action").get("selected"))
	assert(not korean.get_node("Action").get("selected"))
	screen._show_page("sound")
	assert(
		DESIGN.shape(screen.canvas, "설정 / 설명").text
		== "전체 음량이 0이면 모든 소리가 꺼져요."
	)
	var music := DESIGN.shape(screen.canvas, "소리 / 배경음 / 슬라이더")
	var music_fill: Panel = DESIGN.shape(music, "Track / fill")
	assert(music_fill.get_theme_stylebox("panel").bg_color.is_equal_approx(Color("#8497a0")))
	var master := DESIGN.shape(screen.canvas, "소리 / 전체 음량 / 슬라이더")
	var master_input: HSlider = master.find_children("*", "HSlider", false, false)[0]
	master_input.value = 70
	assert(
		DESIGN.shape(screen.canvas, "설정 / 설명").text
		== "게임 소리를 편안한 크기로 조절하세요."
	)
	assert(music_fill.get_theme_stylebox("panel").bg_color.is_equal_approx(Color("#559e9a")))
	assert(DESIGN.shape(master, "Thumb / border").position.x == 192.0)
	assert(DESIGN.shape(master, "Track / fill").size.x == 196.0)
	var slider := DESIGN.shape(screen.canvas, "소리 / 효과음 / 슬라이더")
	var input: HSlider
	for child: Node in slider.get_children():
		if child is HSlider:
			input = child
	input.value = 82
	assert(settings.values.effects == 82.0)
	assert(DESIGN.shape(screen.canvas, "소리 / 효과음 / 값").text == "82%")
	var thumb: Control = DESIGN.shape(slider, "Thumb / border")
	input.value = 0
	assert(thumb.position.x >= 0.0, "Zero volume keeps the whole thumb inside the slider")
	input.value = 100
	assert(
		thumb.position.x + thumb.size.x <= slider.size.x,
		"Maximum volume keeps the whole thumb inside the slider"
	)
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
