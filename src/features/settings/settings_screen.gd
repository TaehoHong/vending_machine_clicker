extends Control

signal closed

const DESIGN = preload("res://src/shared/ui/design_view.gd")
const VIEWS = {
	"base": preload("res://src/features/settings/base_design.tscn"),
	"sound": preload("res://src/features/settings/sound_design.tscn"),
	"display": preload("res://src/features/settings/display_design.tscn"),
	"language": preload("res://src/features/settings/language_design.tscn"),
}
var page: String = "base"
var canvas: Control
var from_title: bool = false
var previous_focus: Control


func _ready() -> void:
	resized.connect(_layout)


func open(title: bool) -> void:
	from_title = title
	previous_focus = get_viewport().gui_get_focus_owner()
	show()
	_show_page("base")


func _show_page(next: String) -> void:
	page = next
	if is_instance_valid(canvas):
		remove_child(canvas)
		canvas.queue_free()
	canvas = VIEWS[page].instantiate()
	add_child(canvas)
	_layout()
	var back: Button = DESIGN.action(canvas, "키보드 조작 / 돌아가기", go_back)
	back.grab_focus()
	if page == "base":
		for entry in [["소리", "sound"], ["화면", "display"], ["언어", "language"]]:
			DESIGN.action(canvas, "설정 / %s / 버튼" % entry[0], _show_page.bind(entry[1]))
		if from_title:
			DESIGN.shape(canvas, "키보드 조작 / 돌아가기").text = "ESC  타이틀로 돌아가기"
	elif page == "language":
		for entry in [
			["한국어 · 선택됨", "ko"], ["English", "en"], ["日本語", "ja"],
			["简体中文", "zh_CN"], ["繁體中文", "zh_TW"],
		]:
			var source_name: String = "언어 / %s / 버튼" % entry[0]
			DESIGN.action(canvas, source_name, _set_preference.bind("locale", entry[1]))
	elif page == "display":
		for entry in [
			["화면 / 창 모드 / 선택됨", "fullscreen", false],
			["화면 / 전체 화면", "fullscreen", true],
			["화면 / 흔들림 줄이기 / 끔", "reduce_motion", false],
			["화면 / 흔들림 줄이기 / 켬", "reduce_motion", true],
		]:
			DESIGN.action(canvas, entry[0], _set_preference.bind(entry[1], entry[2]))
	elif page == "sound":
		for entry in [["전체 음량", "master"], ["배경음", "music"], ["효과음", "effects"]]:
			var artwork := DESIGN.shape(canvas, "소리 / %s / 슬라이더" % entry[0])
			var source_amount: Label = DESIGN.shape(canvas, "소리 / %s / 값" % entry[0])
			artwork.set_meta("source_value", float(source_amount.text.trim_suffix("%")))
			artwork.set_meta("source_thumb_x", DESIGN.shape(artwork, "Thumb / border").position.x)
			var slider := HSlider.new()
			slider.min_value = 0
			slider.max_value = 100
			slider.step = 1
			slider.value = get_node("/root/Preferences").values[entry[1]]
			var empty := ImageTexture.create_from_image(
				Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
			)
			for state in ["grabber", "grabber_highlight", "grabber_disabled"]:
				slider.add_theme_icon_override(state, empty)
			for state in ["slider", "grabber_area", "grabber_area_highlight"]:
				slider.add_theme_stylebox_override(state, StyleBoxEmpty.new())
			artwork.add_child(slider)
			slider.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			slider.value_changed.connect(_volume_changed.bind(entry[1]))
	_refresh_values()


func _set_preference(key: String, value: Variant) -> void:
	get_node("/root/Preferences").set_preference(key, value)
	_refresh_values()


func _volume_changed(value: float, key: String) -> void:
	get_node("/root/Preferences").set_preference(key, value)
	_refresh_values()


func _refresh_values() -> void:
	var preferences: Dictionary = get_node("/root/Preferences").values
	if page == "sound":
		var muted: bool = preferences.master == 0.0
		var description: Label = DESIGN.shape(canvas, "설정 / 설명")
		description.text = (
			"전체 음량이 0이면 모든 소리가 꺼져요." if muted
			else "게임 소리를 편안한 크기로 조절하세요."
		)
		for entry in [["전체 음량", "master"], ["배경음", "music"], ["효과음", "effects"]]:
			var amount: Label = DESIGN.shape(canvas, "소리 / %s / 값" % entry[0])
			amount.text = "%d%%" % int(preferences[entry[1]])
			var slider := DESIGN.shape(canvas, "소리 / %s / 슬라이더" % entry[0])
			var fill: Panel = DESIGN.shape(slider, "Track / fill")
			fill.add_theme_stylebox_override(
				"panel", canvas.get_meta("muted_fill" if muted and entry[1] != "master" else "sound_fill")
			)
			_position_slider(entry[0], float(preferences[entry[1]]))
	elif page == "language":
		for entry in [
			["한국어 · 선택됨", "ko", "한국어"], ["English", "en", "English"],
			["日本語", "ja", "日本語"], ["简体中文", "zh_CN", "简体中文"],
			["繁體中文", "zh_TW", "繁體中文"],
		]:
			var artwork := DESIGN.shape(canvas, "언어 / %s / 버튼" % entry[0])
			var label: Label = DESIGN.shape(artwork, "Label")
			label.text = entry[2] + (" · 선택됨" if preferences.locale == entry[1] else "")
			var action: Button = artwork.get_node("Action")
			if action.has_method("set_selected"):
				action.set_selected(preferences.locale == entry[1])

	elif page == "display":
		for entry in [
			["화면 / 창 모드 / 선택됨", "fullscreen", false, "창 모드"],
			["화면 / 전체 화면", "fullscreen", true, "전체 화면"],
			["화면 / 흔들림 줄이기 / 끔", "reduce_motion", false, "기본 흔들림"],
			["화면 / 흔들림 줄이기 / 켬", "reduce_motion", true, "흔들림 줄이기 · 켬"],
		]:
			var artwork := DESIGN.shape(canvas, entry[0])
			var label: Label = DESIGN.shape(artwork, "Label")
			if label == null:
				label = DESIGN.shape(artwork, "저장 / normal / 문구")
			label.text = entry[3] + (" · 선택됨" if preferences[entry[1]] == entry[2] else "")
			var action: Button = artwork.get_node("Action")
			if action.has_method("set_selected"):
				action.set_selected(preferences[entry[1]] == entry[2])


func _position_slider(label: String, value: float) -> void:
	var artwork := DESIGN.shape(canvas, "소리 / %s / 슬라이더" % label)
	var track: Control = DESIGN.shape(artwork, "Track / border")
	var surface: Control = DESIGN.shape(artwork, "Track / surface")
	var fill: Control = DESIGN.shape(artwork, "Track / fill")
	var border: Control = DESIGN.shape(artwork, "Thumb / border")
	var face: Control = DESIGN.shape(artwork, "Thumb / surface")
	var delta: float = surface.size.x * (value - float(artwork.get_meta("source_value"))) / 100.0
	border.position.x = clampf(
		float(artwork.get_meta("source_thumb_x")) + delta,
		track.position.x, track.position.x + track.size.x - border.size.x
	)
	face.position.x = border.position.x + (border.size.x - face.size.x) * 0.5
	fill.size.x = surface.size.x * value / 100.0


func go_back() -> void:
	if page != "base":
		_show_page("base")
	else:
		hide()
		closed.emit()
		if is_instance_valid(previous_focus):
			previous_focus.grab_focus()


func _input(event: InputEvent) -> void:
	if (
		visible and event is InputEventKey and event.pressed
		and not event.echo and event.keycode == KEY_ESCAPE
	):
		go_back()
		get_viewport().set_input_as_handled()


func _layout() -> void:
	if is_instance_valid(canvas):
		DESIGN.fit(canvas, size)
