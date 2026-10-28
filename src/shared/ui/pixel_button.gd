extends Button

# 프레임만 교차 전환한다. 입력·포커스·signal과 문구는 기본 Button이 소유한다.
var source_frame: Control
var source_state: String = "normal"
var selected: bool = false
var _frames: Dictionary[String, StyleBox] = {}
var _previous: Panel
var _current: Panel
var _state: String = ""
var _transition: Tween
var _source_visible: bool = true


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	expand_icon = true
	if is_instance_valid(source_frame):
		_source_visible = source_frame.visible
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var source := get_theme_stylebox(state)
		_frames[state] = source
		if state == "focus" and not source is StyleBoxTexture:
			_frames[state] = _frames["normal"]
			continue
		var content: StyleBox = source.duplicate()
		if content is StyleBoxTexture:
			content.modulate_color = Color(1, 1, 1, 0)
		elif content is StyleBoxFlat:
			content.bg_color.a = 0.0
			content.border_color.a = 0.0
			content.shadow_color.a = 0.0
		add_theme_stylebox_override(state, content)
	_previous = _make_frame()
	_current = _make_frame()
	_sync_state(true)


func _make_frame() -> Panel:
	var frame := Panel.new()
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.show_behind_parent = true
	add_child(frame)
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return frame


func _process(_delta: float) -> void:
	_sync_state()


func set_selected(value: bool) -> void:
	selected = value
	if is_node_ready():
		_sync_state()


func _sync_state(immediate: bool = false) -> void:
	var next: String = "normal"
	if disabled:
		next = "disabled"
	elif is_pressed():
		next = "pressed"
	elif selected or has_focus():
		next = "focus"
	elif is_hovered():
		next = "hover"
	if next == _state:
		return
	if is_instance_valid(_transition):
		_transition.kill()
	# 기본 상태는 색·숨김이 덮어써진 원본 인스턴스를 그대로 그린다.
	var native: bool = is_instance_valid(source_frame) and next == source_state
	if is_instance_valid(source_frame):
		source_frame.visible = native and _source_visible
	if native:
		_previous.hide()
		_current.hide()
		_state = next
		return
	_current.show()
	_previous.add_theme_stylebox_override("panel", _frames.get(_state, _frames[next]))
	_current.add_theme_stylebox_override("panel", _frames[next])
	_state = next
	_current.modulate.a = 1.0 if immediate else 0.0
	if immediate:
		_previous.hide()
		return
	_previous.show()
	var duration: float = 0.09 if next == "hover" else (0.06 if next == "pressed" else 0.1)
	_transition = create_tween()
	_transition.tween_property(_current, "modulate:a", 1.0, duration)
	_transition.tween_callback(_previous.hide)
