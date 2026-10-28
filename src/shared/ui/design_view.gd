extends RefCounted

# Penpot에서 추출한 네이티브 씬의 이름으로 기존 화면 동작을 연결한다.
const PIXEL_BUTTON = preload("res://src/shared/ui/pixel_button.gd")
const THEME = preload("res://src/shared/ui/themes/play_theme.tres")
const FRAME_TYPES = {
	"136x56": &"Button",
	"192x64": &"SecondaryButton",
	"224x64": &"PrimaryButton",
	"56x56": &"PixelIconButton",
}

static func shape(root: Node, source_name: String) -> Control:
	if root.get_meta("penpot_name", "") == source_name:
		return root as Control
	for child: Node in root.get_children():
		var found := shape(child, source_name)
		if found != null:
			return found
	return null


static func action(root: Node, source_name: String, callback: Callable) -> Button:
	var artwork := shape(root, source_name)
	assert(artwork != null, "Missing Penpot component: " + source_name)
	var frame: Control
	for child: Node in artwork.get_children():
		var name: String = child.get_meta("penpot_name", "")
		if name.contains("Frame") or name.contains("프레임"):
			frame = child as Control
			break
	var family: String = frame.get_meta("penpot_frame_family", "") if frame != null else ""
	var pixel_frame := not family.is_empty() and frame.visible
	var button: Button
	if pixel_frame:
		var pixel := PIXEL_BUTTON.new()
		pixel.source_frame = frame
		pixel.source_state = frame.get_meta("penpot_frame_state", "normal")
		pixel.selected = pixel.source_state == "focus"
		pixel.disabled = pixel.source_state == "disabled"
		button = pixel
	else:
		button = Button.new()
	button.name = "Action"
	button.theme = THEME
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if not pixel_frame:
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	else:
		button.theme_type_variation = FRAME_TYPES[family]
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			var style: StyleBoxTexture = THEME.get_stylebox(
				state, button.theme_type_variation
			).duplicate()
			var factor := frame.size / style.texture.get_size()
			for edge in ["left", "top", "right", "bottom"]:
				var property: String = "texture_margin_" + edge
				var scale: float = factor.x if edge in ["left", "right"] else factor.y
				style.set(property, float(style.get(property)) * scale)
			button.add_theme_stylebox_override(state, style)
	artwork.add_child(button)
	artwork.move_child(button, 0)
	if frame != null:
		button.position = frame.position
		button.size = frame.size
	else:
		button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(callback)
	return button


static func fit(canvas: Control, viewport_size: Vector2) -> void:
	var design_size := Vector2(1152, 648)
	var factor := minf(viewport_size.x / design_size.x, viewport_size.y / design_size.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (viewport_size - design_size * factor) * 0.5


static func fit_text(label: Label, width: float, maximum: int = 24, minimum: int = 12) -> void:
	label.clip_text = true
	label.size.x = width
	var font: Font = label.get_theme_font("font")
	var font_size: int = maximum
	while (
		font_size > minimum
		and font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width
	):
		font_size -= 1
	label.add_theme_font_size_override("font_size", font_size)
