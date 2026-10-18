extends SceneTree

class PreviewGame extends "res://game.gd":
	func _load_progress() -> void: pass
	func _save_progress() -> void: pass

class InsertFX extends Control:
	var elapsed: float = 0.0
	var target: Vector2
	var coin_position: Vector2
	var coin_scale := Vector2.ONE
	var tilt: float = 0.0
	var opacity: float = 0.0
	var flash: float = 0.0
	var font = preload("res://ui/fonts/DoHyeon-Regular.ttf")

	func advance(time: float) -> void:
		elapsed = time
		var start := target + Vector2(76, 72)
		if time < 0.18:
			var t := clampf(time / 0.18, 0, 1)
			coin_position = start + Vector2(0, 8 * (1 - t))
			coin_scale = Vector2.ONE * lerpf(0.65, 1.0, sin(t * PI * 0.5))
			tilt = lerpf(-0.3, -0.15, t)
			opacity = t
		elif time < 0.65:
			var t := clampf((time - 0.18) / 0.47, 0, 1)
			var travel := t * t * (3 - 2 * t)
			var control := target + Vector2(60, -34)
			coin_position = (1 - travel) * (1 - travel) * start + 2 * (1 - travel) * travel * control + travel * travel * target
			coin_scale = Vector2(lerpf(1.0, 0.22, travel), lerpf(1.0, 0.72, travel))
			tilt = lerpf(-0.15, 0.0, travel)
			opacity = 1.0
		elif time < 0.8:
			var t := (time - 0.65) / 0.15
			coin_position = target + Vector2(-3 * t, -3 * t)
			coin_scale = Vector2(lerpf(0.22, 0.02, t), lerpf(0.72, 0.36, t))
			tilt = 0
			opacity = 1 - t
		else:
			opacity = 0
		flash = sin(clampf((time - 0.69) / 0.3, 0, 1) * PI)
		queue_redraw()

	func _draw() -> void:
		if flash > 0.0:
			var radius := 10 + 7 * flash
			var color := Color(0.7, 0.95, 1, flash * 0.9)
			for direction in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
				var p: Vector2 = target + direction * radius
				draw_line(p, p + direction * 3, color, 2)
		if opacity <= 0:
			return
		draw_set_transform(coin_position, tilt, coin_scale)
		var edge := PackedVector2Array([Vector2(-9, -18), Vector2(9, -18), Vector2(15, -12), Vector2(18, -6), Vector2(18, 6), Vector2(15, 12), Vector2(9, 18), Vector2(-9, 18), Vector2(-15, 12), Vector2(-18, 6), Vector2(-18, -6), Vector2(-15, -12)])
		draw_colored_polygon(edge, Color(0.05, 0.07, 0.1, opacity))
		draw_set_transform(coin_position, tilt, coin_scale * 0.88)
		draw_colored_polygon(edge, Color(0.66, 0.76, 0.84, opacity))
		draw_arc(Vector2.ZERO, 14, PI * 0.95, PI * 1.95, 12, Color(0.97, 1, 1, opacity), 3)
		draw_arc(Vector2.ZERO, 14, -0.05, PI * 0.95, 12, Color(0.33, 0.45, 0.56, opacity), 2)
		draw_arc(Vector2.ZERO, 11, 0, TAU, 16, Color(0.78, 0.89, 0.95, opacity), 1)
		draw_string(font, Vector2(-10, 5), "100", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.12, 0.25, 0.34, opacity))
		var shine := maxf(0.0, sin(elapsed * 10)) * opacity
		draw_line(Vector2(-10, -10), Vector2(-2, -10), Color(1, 1, 1, shine), 2)
		draw_line(Vector2(-6, -14), Vector2(-6, -6), Color(1, 1, 1, shine), 2)
		draw_set_transform(Vector2.ZERO)

func _initialize() -> void:
	call_deferred("render_preview")

func render_preview() -> void:
	DirAccess.make_dir_recursive_absolute("res://.godot/insert-concept-frames")
	var game = load("res://Game.tscn").instantiate()
	game.set_script(PreviewGame)
	root.add_child(game)
	game.money = 1250
	game._refresh_ui()
	game.search_hint.hide()
	game.search_hint.set_process(false)
	var fx := InsertFX.new()
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.z_index = 10
	fx.target = game.get_node("VendingMachine").position + Vector2(855, 648) * (game.get_node("VendingMachine").size.x / 1024)
	game.add_child(fx)
	for frame in range(50):
		fx.advance(maxf(0.0, float(frame) / 30.0 - 0.2))
		await process_frame
		await RenderingServer.frame_post_draw
		var picture := root.get_texture().get_image()
		picture.save_png("res://.godot/insert-concept-frames/%03d.png" % frame)
		if frame == 15:
			picture.save_png("res://design/coin-insert-concept/preview.png")
	assert(game.money == 1250 and game.drinks == 0)
	game.free()
	print("Coin insertion concept rendered without changing purchase state.")
	quit()
