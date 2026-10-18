extends SceneTree

const FONT = preload("res://ui/fonts/DoHyeon-Regular.ttf")
const ALLEY = preload("res://images/alley_arcade_penpot.png")
const MACHINE = preload("res://images/vending_arcade_penpot.png")
const COIN = preload("res://ui/search_coin.gd")
const GOLD = Color("ffe48c")
const INK = Color("12121d")

func _initialize() -> void:
	call_deferred("render_all")

func box(parent: Node, rect: Rect2, color: Color) -> ColorRect:
	var item := ColorRect.new()
	item.position = rect.position
	item.size = rect.size
	item.color = color
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item

func text(parent: Node, value: String, rect: Rect2, font_size: int, color: Color = Color.WHITE, center: bool = false) -> Label:
	var item := Label.new()
	item.text = value
	item.position = rect.position
	item.size = rect.size
	item.add_theme_font_override("font", FONT)
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	item.add_theme_color_override("font_outline_color", INK)
	item.add_theme_constant_override("outline_size", 3)
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if center else HORIZONTAL_ALIGNMENT_LEFT
	item.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item

func art(parent: Node, texture: Texture2D, rect: Rect2) -> TextureRect:
	var item := TextureRect.new()
	item.texture = texture
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.position = rect.position
	item.size = rect.size
	item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item

func panel(parent: Node, rect: Rect2, style: String = "ability") -> Panel:
	var item := Panel.new()
	item.position = rect.position
	item.size = rect.size
	item.add_theme_stylebox_override("panel", load("res://ui/pixel/%s_style.tres" % style))
	parent.add_child(item)
	return item

func button(parent: Node, value: String, rect: Rect2, style: String = "ability") -> void:
	panel(parent, rect, style)
	text(parent, value, Rect2(rect.position + Vector2(8, 0), rect.size - Vector2(20, 8)), 30, Color.WHITE, true)

func coin(parent: Node, position: Vector2, tier: int, factor: float = 1.0) -> void:
	var item = COIN.new()
	item.tier = tier
	item.position = position
	item.scale = Vector2.ONE * factor
	parent.add_child(item)

func glow(parent: Node, rect: Rect2, color: Color) -> void:
	var texture := GradientTexture2D.new()
	texture.width = 512
	texture.height = 256
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1, 0.5)
	texture.gradient = Gradient.new()
	texture.gradient.colors = PackedColorArray([color, Color(color, 0)])
	var image := art(parent, texture, rect)
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func screen() -> Control:
	var page := Control.new()
	page.size = Vector2(1152, 648)
	root.add_child(page)
	var background := art(page, ALLEY, Rect2(0, 0, 1152, 648))
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	return page

func concept_a() -> Control:
	var page := screen()
	box(page, Rect2(0, 0, 560, 648), Color(0.05, 0.1, 0.17, 0.78))
	box(page, Rect2(552, 0, 6, 648), Color("28567f"))
	text(page, "자판기 클릭커", Rect2(52, 42, 420, 34), 22, GOLD)
	text(page, "BACKSTREET", Rect2(48, 82, 500, 70), 58)
	text(page, "CLICKER", Rect2(48, 140, 450, 76), 68, GOLD)
	text(page, "골목의 작은 동전에서 시작되는 이야기", Rect2(52, 218, 450, 32), 21, Color("d1e5eb"))
	button(page, "New Game", Rect2(52, 294, 394, 68))
	button(page, "Load Game", Rect2(52, 378, 394, 68), "drinks")
	text(page, "Exit", Rect2(52, 464, 394, 40), 24, Color("cad5dc"), true)
	box(page, Rect2(54, 550, 390, 2), Color("4b7085"))
	text(page, "동전을 찾고 · 음료를 모으고 · 다음 골목으로", Rect2(52, 566, 450, 34), 19, Color("c0d7e2"))
	glow(page, Rect2(600, 492, 490, 118), Color(1, 0.8, 0.4, 0.56))
	art(page, MACHINE, Rect2(654, 8, 410, 615))
	coin(page, Vector2(696, 550), 0, 1.3)
	coin(page, Vector2(926, 570), 1, 1.0)
	return page

func concept_b() -> Control:
	var page := screen()
	box(page, Rect2(0, 0, 1152, 648), Color(0.02, 0.07, 0.17, 0.65))
	text(page, "BACKSTREET CLICKER", Rect2(70, 28, 1012, 88), 68, GOLD, true)
	text(page, "동전을 찾고, 음료를 모으고, 골목 너머로.", Rect2(160, 115, 832, 36), 23, Color("d3ecf4"), true)
	glow(page, Rect2(280, 170, 590, 390), Color(0.34, 0.63, 0.85, 0.36))
	glow(page, Rect2(310, 480, 530, 78), Color(1, 0.77, 0.35, 0.7))
	art(page, MACHINE, Rect2(422, 132, 308, 462))
	coin(page, Vector2(422, 452), 0, 1.0)
	coin(page, Vector2(706, 433), 1, 1.0)
	coin(page, Vector2(380, 498), 2, 1.2)
	coin(page, Vector2(750, 493), 3, 1.2)
	button(page, "New Game", Rect2(282, 552, 276, 64))
	button(page, "Load Game", Rect2(586, 552, 276, 64), "drinks")
	text(page, "Exit", Rect2(1028, 20, 92, 34), 20, Color("c8d8e2"), true)
	return page

func concept_c() -> Control:
	var page := screen()
	box(page, Rect2(0, 0, 1152, 648), Color(0.03, 0.1, 0.16, 0.3))
	glow(page, Rect2(76, 487, 540, 110), Color(1, 0.8, 0.45, 0.65))
	art(page, MACHINE, Rect2(140, 4, 394, 591))
	coin(page, Vector2(184, 547), 0, 1.3)
	coin(page, Vector2(271, 568), 1, 1.1)
	coin(page, Vector2(366, 563), 2, 1.1)
	coin(page, Vector2(463, 540), 3, 1.3)
	panel(page, Rect2(636, 58, 454, 536))
	text(page, "자판기 클릭커", Rect2(666, 91, 386, 34), 22, GOLD)
	text(page, "BACKSTREET", Rect2(662, 143, 390, 64), 49)
	text(page, "CLICKER", Rect2(662, 202, 386, 66), 60, GOLD)
	box(page, Rect2(666, 285, 382, 3), Color("28567f"))
	text(page, "오늘은 어떤 음료를 만나게 될까요?", Rect2(666, 299, 386, 40), 21)
	button(page, "New Game", Rect2(666, 355, 382, 66), "drinks")
	button(page, "Load Game", Rect2(666, 437, 382, 66))
	text(page, "Exit", Rect2(666, 520, 382, 38), 23, Color("d4e7f1"), true)
	return page

func render_all() -> void:
	for kind in ["a", "b", "c"]:
		var page: Control = call("concept_" + kind)
		await process_frame
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png("res://design/main-menu-concepts/main-%s.png" % kind)
		assert(error == OK)
		page.free()
		await process_frame
	print("Three main menu concepts rendered with actual game assets.")
	quit()
