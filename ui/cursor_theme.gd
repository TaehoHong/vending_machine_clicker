extends Node

const CURSOR = preload("res://ui/pixel/cursor.svg")
const PRESSED_CURSOR = preload("res://ui/pixel/cursor_press.svg")
const REBOUND_CURSOR = preload("res://ui/pixel/cursor_rebound.svg")
const HOTSPOT = Vector2(12, 3)
const MINIMUM_PRESS_TIME = 0.09
const REBOUND_TIME = 0.055

var current_texture: Texture2D
var held: bool = false
var press_remaining: float = 0.0
var rebound_remaining: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_cursor(CURSOR)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		held = event.pressed
		if held:
			press_remaining = MINIMUM_PRESS_TIME
			rebound_remaining = REBOUND_TIME
			_apply_cursor(PRESSED_CURSOR)

func _process(delta: float) -> void:
	if held:
		press_remaining = maxf(0.0, press_remaining - delta)
	elif press_remaining > 0.0:
		press_remaining = maxf(0.0, press_remaining - delta)
	elif rebound_remaining > 0.0:
		_apply_cursor(REBOUND_CURSOR)
		rebound_remaining = maxf(0.0, rebound_remaining - delta)
	else:
		_apply_cursor(CURSOR)

func _apply_cursor(texture: Texture2D) -> void:
	if current_texture == texture:
		return
	current_texture = texture
	# 버튼의 pointing-hand 상태에서도 같은 Penpot 커서를 유지한다.
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, HOTSPOT)
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_POINTING_HAND, HOTSPOT)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		held = false
		press_remaining = 0.0
		rebound_remaining = 0.0
		_apply_cursor(CURSOR)

func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
