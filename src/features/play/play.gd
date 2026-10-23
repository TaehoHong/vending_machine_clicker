extends Control

signal save_requested
signal quit_requested

const SESSION = preload("res://src/game/game_session.gd")
const AMOUNTS = preload("res://src/shared/formatting/amount_format.gd")
const DRINK_DATA = preload("res://src/data/drink_catalog.gd").DATA
const FEVER_COIN_SCALE: float = 2.5

var session: SESSION = SESSION.new()
var last_save_error: Error = OK

var coin_tween: Tween
var _purchase_animation_active: bool = false
var coin_insert_fx: Control
var drink_dispense_fx: Control
var ability_toast: Control
var ability_receipt_tween: Tween
var search_glow_tween: Tween
var search_hint: Control
var search_fever_fx: Control
var punch_fever_fx: Control
var punch_button: Button
var machine_home := Vector2.ZERO
var machine_hit_tween: Tween
var last_punch_point := Vector2.ZERO
var punch_coin_phase: float = 0.0

@onready var money_label: Label = $MoneyLabel
@onready var earn_button: Button = $EarnButton
@onready var search_glow: TextureRect = $SearchGlow
@onready var quest_progress: Label = $QuestPanel/QuestProgress
@onready var quest_complete_button: Button = $QuestPanel/QuestCompleteButton
@onready var can_count_label: Label = $WalletPanel/CanCount
@onready var info_overlay: ColorRect = $InfoOverlay
@onready var shop_button: Button = $CoinSlotButton
@onready var coin_token: Panel = $CoinToken
@onready var quest_panel: Panel = $QuestPanel
@onready var quest_title: Label = $QuestPanel/QuestTitle
@onready var result_overlay: ColorRect = $ResultOverlay
@onready var result_title: Label = $ResultOverlay/Card/Margin/Contents/DrinkName
@onready var result_art: TextureRect = $ResultOverlay/Card/Margin/Contents/DrinkArt
@onready var result_effect: RichTextLabel = $ResultOverlay/Card/Margin/Contents/Effect
@onready var close_button: Button = $ResultOverlay/Card/Margin/Contents/CloseButton
@onready var feedback_label: Label = $FeedbackLabel
@onready var pause_menu: CanvasLayer = $PauseMenu


func _ready() -> void:
	_setup_drink_catalog()
	pause_menu.escape_requested.connect(_on_escape_requested)
	$InfoOverlay/Card/SkillTree.close_requested.connect(_on_info_close_pressed)
	ability_toast = preload("res://src/features/play/effects/ability_toast.gd").new()
	ability_toast.name = "AbilityToast"
	add_child(ability_toast)
	move_child(ability_toast, result_overlay.get_index())
	drink_dispense_fx = preload("res://src/features/play/effects/drink_dispense_fx.gd").new()
	drink_dispense_fx.name = "DrinkDispenseFX"
	add_child(drink_dispense_fx)
	move_child(drink_dispense_fx, info_overlay.get_index())
	search_hint = preload("res://src/features/play/effects/search_hint.gd").new()
	search_hint.name = "SearchHint"
	add_child(search_hint)
	move_child(search_hint, result_overlay.get_index())
	search_fever_fx = preload("res://src/features/play/effects/search_fever.gd").new()
	search_fever_fx.name = "SearchFeverFX"
	add_child(search_fever_fx)
	move_child(search_fever_fx, result_overlay.get_index())
	punch_fever_fx = preload("res://src/features/play/effects/punch_fever.gd").new()
	punch_fever_fx.name = "PunchFeverFX"
	add_child(punch_fever_fx)
	move_child(punch_fever_fx, result_overlay.get_index())
	punch_button = Button.new()
	punch_button.name = "PunchButton"
	punch_button.focus_mode = Control.FOCUS_NONE
	punch_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		punch_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	add_child(punch_button)
	move_child(punch_button, result_overlay.get_index())
	punch_button.pressed.connect(_on_punch_button_pressed)
	punch_button.gui_input.connect(
		func(event: InputEvent) -> void:
			if (
				event is InputEventMouseButton
				and event.pressed
				and event.button_index == MOUSE_BUTTON_LEFT
			):
				last_punch_point = punch_button.position + event.position
	)
	punch_button.hide()
	_setup_coin_slot()
	_setup_search_area()
	resized.connect(_position_coin_slot)
	_refresh_ui()


func _process(delta: float) -> void:
	var blocked: bool = result_overlay.visible or info_overlay.visible
	search_hint.set(
		"blocked",
		blocked or session.search_fever_remaining > 0 or session.punch_fever_remaining > 0
	)
	var search_was_active: bool = session.search_fever_remaining > 0
	var punch_was_active: bool = session.punch_fever_remaining > 0
	session.advance(delta, blocked)
	if search_was_active and session.search_fever_remaining == 0:
		_refresh_ui()
	if punch_was_active and session.punch_fever_remaining == 0:
		_restore_machine_position()
	search_fever_fx.call(
		"update_state",
		session.search_fever_remaining,
		session.search_fever_total,
		blocked or session.punch_fever_remaining > 0
	)
	punch_fever_fx.call(
		"update_state", session.punch_fever_remaining, session.punch_fever_total, blocked
	)
	punch_button.visible = session.punch_fever_remaining > 0 and not blocked
	get_node("/root/CursorTheme").call(
		"set_punch_mode", session.punch_fever_remaining > 0 and not blocked
	)


func _start_punch_fever() -> void:
	session.start_punch_fever()
	_process(0)
	_refresh_ui()


func _restore_machine_position() -> void:
	if is_instance_valid(machine_hit_tween):
		machine_hit_tween.kill()
	$VendingMachine.position = machine_home
	$VendingMachine.modulate = Color.WHITE


func _on_punch_button_pressed() -> void:
	if (
		get_tree().paused
		or result_overlay.visible
		or info_overlay.visible
		or session.punch_fever_remaining <= 0
	):
		return
	if not punch_button.get_rect().has_point(last_punch_point):
		last_punch_point = get_local_mouse_position()
		if not punch_button.get_rect().has_point(last_punch_point):
			last_punch_point = punch_button.get_rect().get_center()
	punch_fever_fx.call("add_hit", last_punch_point)
	_restore_machine_position()
	machine_hit_tween = $VendingMachine.create_tween()
	machine_hit_tween.tween_property(
		$VendingMachine, "position", machine_home + Vector2(randf_range(-7, 7), -4), 0.035
	)
	machine_hit_tween.parallel().tween_property(
		$VendingMachine, "modulate", Color(1.45, 1.3, 1.2), 0.035
	)
	machine_hit_tween.tween_property(
		$VendingMachine, "position", machine_home + Vector2(randf_range(-4, 4), 2), 0.045
	)
	machine_hit_tween.tween_property($VendingMachine, "position", machine_home, 0.08)
	machine_hit_tween.parallel().tween_property($VendingMachine, "modulate", Color.WHITE, 0.08)
	var earned: int = session.punch()
	if earned == 0:
		_show_empty_search()
	else:
		_show_coin_reward(earned)
	_finish_action("")


func _start_search_fever() -> void:
	session.start_search_fever()
	_refresh_ui()


func _on_earn_button_pressed() -> void:
	if session.punch_fever_remaining > 0:
		_on_punch_button_pressed()
		return
	if (
		get_tree().paused
		or result_overlay.visible
		or info_overlay.visible
	):
		return
	search_hint.call("notify_search_click")
	if session.search_fever_remaining > 0:
		var point := get_local_mouse_position()
		if not earn_button.get_rect().has_point(point):
			point = earn_button.position + earn_button.size * Vector2(0.5, 0.35)
		search_fever_fx.call("add_click", point)
	var earned: int = session.search()
	if earned < 0:
		_refresh_ui()
		return
	if earned == 0:
		_show_empty_search()
	else:
		_show_coin_reward(earned)
	_finish_action("")


func _show_coin_reward(amount: int) -> void:
	_clear_search_popups("empty_search_popups")
	_show_search_coin(amount)
	var popup := Label.new()
	popup.name = "CoinRewardPopup"
	popup.text = "+%d" % amount
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.add_theme_font_override("font", preload("res://assets/fonts/Cafe24PROUP.ttf"))
	popup.add_theme_font_size_override("font_size", 28)
	popup.add_theme_color_override("font_color", Color("f2bd62"))
	popup.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.06, 0.95))
	popup.add_theme_constant_override("outline_size", 6)
	_animate_search_popup(popup, "coin_reward_popups")


func _show_empty_search() -> void:
	_clear_search_popups("coin_reward_popups")
	_clear_search_popups("search_coin_effects")
	var popup := TextureRect.new()
	popup.name = "EmptySearchPopup"
	popup.texture = preload("res://src/features/play/effects/crying_icon.svg")
	popup.custom_minimum_size = Vector2(42, 42)
	popup.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	popup.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_animate_search_popup(popup, "empty_search_popups")


func _show_search_coin(amount: int) -> void:
	if session.search_fever_remaining <= 0 and session.punch_fever_remaining <= 0:
		_clear_search_popups("search_coin_effects")
	punch_coin_phase = randf()
	var counts: Array[int] = preload("res://src/features/play/effects/search_coin.gd").breakdown(
		amount
	)
	var total: int = counts[0] + counts[1] + counts[2] + counts[3]
	var index: int = 0
	for tier in range(counts.size() - 1, -1, -1):
		for _i in range(counts[tier]):
			_spawn_search_coin(tier, index, total)
			index += 1


func _spawn_search_coin(tier: int, index: int, total: int) -> void:
	var coin: Control = preload("res://src/features/play/effects/search_coin.gd").new()
	coin.set("tier", tier)
	coin.name = "FoundCoin"
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin.size = Vector2(26, 26)
	coin.pivot_offset = coin.size * 0.5
	coin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(coin)
	move_child(coin, result_overlay.get_index())
	coin.add_to_group("search_coin_effects")
	if session.punch_fever_remaining > 0:
		move_child(coin, punch_fever_fx.get_index())
	var lane := float(index) / maxf(1.0, total - 1.0)
	var start := (
		search_glow.position
		+ Vector2(search_glow.size.x * lerpf(0.25, 0.75, lane), 0)
		- coin.size * 0.5
	)
	if session.punch_fever_remaining > 0:
		start = _punch_coin_origin(index, total) - coin.size * 0.5
	coin.position = start
	if session.punch_fever_remaining > 0:
		_animate_punch_coin(coin, start)
		return
	if session.search_fever_remaining > 0:
		_animate_fever_coin(coin, start, index, total)
		return
	var direction := -1.0 if index % 2 == 0 else 1.0
	var height := randf_range(22, 48)
	var distance := randf_range(45, 90)
	var motion := coin.create_tween()
	(
		motion
		. tween_property(coin, "position", start + Vector2(direction * 12, -height), 0.16)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_OUT)
	)
	(
		motion
		. tween_property(coin, "position", start + Vector2(direction * 28, 18), 0.22)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_IN)
	)
	(
		motion
		. tween_property(coin, "position", start + Vector2(direction * distance, 22), 0.38)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_OUT)
	)
	motion.tween_callback(coin.queue_free)
	var spin := coin.create_tween()
	spin.tween_property(coin, "rotation", direction * TAU, 0.76)
	var fade := coin.create_tween()
	fade.tween_interval(0.48)
	fade.tween_property(coin, "modulate:a", 0.0, 0.28)


func _animate_fever_coin(coin: Control, start: Vector2, index: int, total: int) -> void:
	coin.scale = Vector2.ONE * FEVER_COIN_SCALE
	# 여러 동전은 부채꼴로 분산하고, 한 개일 때도 매번 다른 방향으로 튀긴다.
	var lane := float(index) / float(total - 1) if total > 1 else randf()
	var spread := lerpf(-310.0, 310.0, lane) + randf_range(-35, 35)
	var landing := start + Vector2(spread, randf_range(-90, 45))
	landing.x = clampf(landing.x, 70, maxf(70, size.x - 96))
	landing.y = clampf(landing.y, 100, maxf(100, size.y - 100))
	var height := randf_range(135, 230)
	var lifetime := randf_range(0.95, 1.15)
	var direction := -1.0 if spread < 0 else 1.0
	var motion := coin.create_tween()
	motion.tween_method(
		func(t: float) -> void:
			coin.position = start.lerp(landing, t) + Vector2(0, -4.0 * height * t * (1.0 - t)),
		0.0,
		1.0,
		lifetime
	)
	motion.tween_callback(coin.queue_free)
	var spin := coin.create_tween()
	spin.tween_property(coin, "rotation", direction * TAU * randf_range(1.0, 1.5), lifetime)
	var fade := coin.create_tween()
	fade.tween_interval(lifetime * 0.65)
	fade.tween_property(coin, "modulate:a", 0.0, lifetime * 0.35)


func _punch_coin_origin(index: int, total: int) -> Vector2:
	var rect := punch_button.get_rect().grow(-8)
	var edge := fposmod(punch_coin_phase + float(index) / maxi(1, total), 1.0) * 4
	if edge < 1:
		return rect.position + Vector2(rect.size.x * edge, 0)
	if edge < 2:
		return rect.position + Vector2(rect.size.x, rect.size.y * (edge - 1))
	if edge < 3:
		return rect.end - Vector2(rect.size.x * (edge - 2), 0)
	return rect.position + Vector2(0, rect.size.y * (4 - edge))


func _animate_punch_coin(coin: Control, start: Vector2) -> void:
	coin.scale = Vector2.ONE * FEVER_COIN_SCALE
	var direction := (
		(start + coin.size * 0.5 - punch_button.get_rect().get_center())
		. normalized()
		. rotated(randf_range(-0.25, 0.25))
	)
	var end := start + direction * randf_range(160, 290) + Vector2(0, 55)
	end.x = clampf(end.x, 35, maxf(35, size.x - 61))
	end.y = clampf(end.y, 110, maxf(110, size.y - 55))
	var lifetime := randf_range(0.75, 1.0)
	var arc := randf_range(25, 65)
	var motion := coin.create_tween()
	motion.tween_method(
		func(t: float) -> void: coin.position = start.lerp(end, t) + Vector2(0, -sin(t * PI) * arc),
		0.0,
		1.0,
		lifetime
	)
	motion.tween_callback(coin.queue_free)
	var spin := coin.create_tween()
	spin.tween_property(coin, "rotation", randf_range(-TAU * 2, TAU * 2), lifetime)
	var fade := coin.create_tween()
	fade.tween_interval(lifetime * 0.6)
	fade.tween_property(coin, "modulate:a", 0.0, lifetime * 0.4)


func _clear_search_popups(popup_group: String) -> void:
	for popup in get_tree().get_nodes_in_group(popup_group):
		popup.hide()
		popup.remove_from_group(popup_group)
		popup.queue_free()


func _animate_search_popup(popup: Control, popup_group: String) -> void:
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(popup)
	# 획득 창 뒤에 배치하고 클릭을 가리지 않는다.
	move_child(popup, result_overlay.get_index())
	popup.add_to_group(popup_group)
	popup.size = popup.get_minimum_size()
	popup.pivot_offset = popup.size * 0.5
	var origin: Vector2 = get_local_mouse_position()
	if session.punch_fever_remaining > 0:
		origin = last_punch_point
	elif not earn_button.get_rect().has_point(origin):
		origin = earn_button.position + earn_button.size * 0.5
	popup.position = origin + Vector2(randf_range(-36, 36), -randf_range(28, 48)) - popup.size * 0.5
	popup.position.x = clampf(popup.position.x, 8, maxf(8, size.x - popup.size.x - 8))
	popup.scale = Vector2(0.55, 0.55)
	var start: Vector2 = popup.position
	var drift: float = randf_range(-24, 24)
	var motion := popup.create_tween()
	(
		motion
		. tween_property(popup, "position", start + Vector2(drift * 0.4, -48), 0.22)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_OUT)
	)
	(
		motion
		. tween_property(popup, "position", start + Vector2(drift, -92), 0.73)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)
	motion.tween_callback(popup.queue_free)
	var bounce := popup.create_tween()
	(
		bounce
		. tween_property(popup, "scale", Vector2(1.2, 1.2), 0.14)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	bounce.tween_property(popup, "scale", Vector2.ONE, 0.12)
	var fade := popup.create_tween()
	fade.tween_interval(0.3)
	fade.tween_property(popup, "modulate:a", 0.0, 0.65)


func _setup_search_area() -> void:
	# 본체와 다리가 빛을 가려, 자판기 안쪽 틈에서 새어 나오도록 배치한다.
	move_child(search_glow, $VendingMachine.get_index())
	# 모든 버튼 상태를 투명하게 두어 배경 위에 클릭 영역만 남긴다.
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		earn_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	search_glow.modulate.a = clampf(
		float(session.click_stack) / session.clicks_required(), 0.0, 1.0
	)
	search_glow.call("set_progress", search_glow.modulate.a)


func _refresh_search_glow() -> void:
	if search_glow_tween and search_glow_tween.is_valid():
		search_glow_tween.kill()
	var brightness: float = clampf(float(session.click_stack) / session.clicks_required(), 0.0, 1.0)
	if session.search_fever_remaining > 0:
		brightness = maxf(0.35, brightness)
	search_glow.call("set_progress", brightness)
	search_glow_tween = create_tween()
	search_glow_tween.tween_property(search_glow, "modulate:a", brightness, 0.18)


func _on_quest_complete_button_pressed() -> void:
	if (
		get_tree().paused
		or result_overlay.visible
		or info_overlay.visible
	):
		return
	if session.claim_quest():
		_finish_action("")


func _setup_coin_slot() -> void:
	# 비활성화 상태에도 기본 테마의 사각형이 나타나지 않도록 모두 투명 처리.
	for state in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		shop_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	coin_token.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	coin_token.get_node("Symbol").hide()
	coin_insert_fx = preload("res://src/features/play/effects/coin_insert_fx.gd").new()
	coin_insert_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin_token.add_child(coin_insert_fx)
	_position_coin_slot()


func _position_coin_slot() -> void:
	# 배경의 KEEP_ASPECT_COVER 변환에 맞춰 독립 자판기를 배치한다.
	var image_size: Vector2 = $TextureRect.texture.get_size()
	var factor: float = maxf(size.x / image_size.x, size.y / image_size.y)
	var origin: Vector2 = (size - image_size * factor) * 0.5
	var machine: TextureRect = $VendingMachine
	machine.position = origin + Vector2(608, 110) * factor
	machine.size = Vector2(384, 576) * factor
	machine_home = machine.position
	# 첨부 이미지 512×768의 투입구와 발밑에 클릭 영역을 맞춘다.
	var machine_scale: float = machine.size.x / 512.0
	punch_button.position = machine.position + Vector2(56, 60) * machine_scale
	punch_button.size = Vector2(400, 670) * machine_scale
	punch_fever_fx.size = size
	# 구매 영역은 실제 본체의 상단부터 음료 배출구 바로 위까지만 포함한다.
	shop_button.position = machine.position + Vector2(56, 60) * machine_scale
	shop_button.size = Vector2(400, 500) * machine_scale
	earn_button.position = machine.position + Vector2(50, 690) * machine_scale
	earn_button.size = Vector2(412, 120) * machine_scale
	search_glow.position = machine.position + Vector2(40, 690) * machine_scale
	search_glow.size = Vector2(432, 110) * machine_scale
	search_hint.position = Vector2(
		earn_button.position.x + earn_button.size.x * 0.5 - search_hint.size.x * 0.5,
		earn_button.position.y + earn_button.size.y * 0.5
	)
	search_fever_fx.size = size
	search_fever_fx.set("source", earn_button.position + earn_button.size * Vector2(0.5, 0.43))
	var slot_target := coin_insertion_target()
	if is_instance_valid(coin_insert_fx):
		coin_insert_fx.set("target", slot_target)
	$SlotHint.position = slot_target + Vector2(76, -30)
	$SlotHint.position.x = minf($SlotHint.position.x, size.x - $SlotHint.size.x - 12)
	ability_toast.position = Vector2((size.x - ability_toast.size.x) * 0.5, 100)
	drink_dispense_fx.set(
		"outlet", machine.position + Vector2(490, 1210) * (machine.size.x / 1024.0)
	)
	drink_dispense_fx.set("destination", ability_receipt_position())


func ability_receipt_position() -> Vector2:
	var button: Button = $Navigation/AbilityButton
	return (
		get_global_transform().affine_inverse()
		* (button.get_global_transform() * (button.size * 0.5))
	)


func _show_acquired_ability(drink_index: int) -> void:
	var data: Dictionary = DRINK_DATA[drink_index]
	ability_toast.call("present", data.name, data.effect, Color(data.color))
	var button: Button = $Navigation/AbilityButton
	if is_instance_valid(ability_receipt_tween):
		ability_receipt_tween.kill()
	button.modulate = Color(1.5, 1.5, 1.5)
	ability_receipt_tween = button.create_tween()
	ability_receipt_tween.tween_property(button, "modulate", Color.WHITE, 0.35)


func coin_insertion_target() -> Vector2:
	var machine: TextureRect = $VendingMachine
	return machine.position + Vector2(855, 648) * (machine.size.x / 1024.0)


func _on_shop_button_pressed() -> void:
	if session.punch_fever_remaining > 0:
		_on_punch_button_pressed()
		return
	if (
		get_tree().paused
		or result_overlay.visible
		or info_overlay.visible
	):
		return
	var price: int = session.current_draw_price()
	if session.money < price:
		feedback_label.text = (
			"음료 뽑기에는 %s Gold가 필요합니다. (%s Gold 부족)"
			% [AMOUNTS.format_amount(price), AMOUNTS.format_amount(price - session.money)]
		)
		return
	if not session.purchase():
		return
	# 차감과 획득을 함께 즉시 저장해 애니메이션 중 종료해도 음료를 잃지 않는다.
	_finish_action("")
	if not _purchase_animation_active:
		_play_purchase_queue()


func _play_purchase_queue() -> void:
	_purchase_animation_active = true
	while not session.pending_purchases.is_empty():
		# 마지막 구매 값 대신 현재 연출 결과를 고정해 뒤의 구매로 덮어쓰지 않는다.
		var drink_index: int = session.pending_purchases[0]
		coin_token.position = Vector2.ZERO
		coin_token.scale = Vector2.ONE
		coin_token.modulate = Color.WHITE
		coin_insert_fx.set("target", coin_insertion_target())
		coin_insert_fx.call("advance", 0.0)
		coin_token.show()
		coin_tween = create_tween()
		coin_tween.tween_method(Callable(coin_insert_fx, "advance"), 0.0, 1.02, 1.02)
		coin_tween.tween_callback(coin_token.hide)
		coin_tween.tween_callback(
			func() -> void:
				drink_dispense_fx.call(
					"begin", load(DRINK_DATA[drink_index].asset), Color(DRINK_DATA[drink_index].color)
				)
		)
		coin_tween.tween_method(Callable(drink_dispense_fx, "advance"), 0.0, 1.32, 1.32)
		coin_tween.tween_callback(
			func() -> void:
				drink_dispense_fx.hide()
				_show_acquired_ability(drink_index)
		)
		await coin_tween.finished
		session.finish_purchase()
		_process(0)
		_refresh_ui()
	_purchase_animation_active = false


func _refresh_vending_display() -> void:
	var slots: int = 0
	for index in session.purchasable_drinks():
		slots |= 1 << int(DRINK_DATA[index].display_slot)
	($VendingMachine.material as ShaderMaterial).set_shader_parameter("unlocked_slots", slots)


func _setup_drink_catalog() -> void:
	var rows: VBoxContainer = $InfoOverlay/Card/Catalog/Rows
	var template: Panel = rows.get_node("Water")
	for data in DRINK_DATA:
		var row: Panel = rows.get_node_or_null(data.key)
		if row == null:
			row = template.duplicate()
			row.name = data.key
			rows.add_child(row)
		row.get_node("Art").texture = load(data.asset)
		row.get_node("Name").text = data.name
		row.get_node("Name").add_theme_color_override("font_color", Color(data.color))
		row.get_node("Rule").text = data.effect


func _update_result() -> void:
	var data: Dictionary = DRINK_DATA[session.last_drink]
	result_title.text = "%s 획득!" % data.name
	result_art.texture = load(data.asset)
	$ResultOverlay/Card/Margin/Contents/Halo.modulate = Color(data.color)
	var headline: String = _drink_cumulative_text(session.last_drink)
	result_effect.text = (
		("[center][font_size=21][color=%s]%s[/color][/font_size]\n"
		+ "[color=#A6B3BF]%s\n빈캔 +1[/color][/center]")
		% [data.color, headline, data.effect]
	)


func _on_result_close_pressed() -> void:
	result_overlay.hide()
	_refresh_ui()
	shop_button.grab_focus()


func _refresh_ui() -> void:
	_refresh_vending_display()
	money_label.text = AMOUNTS.format_gold(session.money) + " Gold"
	money_label.tooltip_text = "보유 골드: %s Gold" % AMOUNTS.format_amount(session.money)
	var font: Font = money_label.get_theme_font("font")
	var font_size: int = 28
	while (
		font_size > 18
		and (
			font.get_string_size(money_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 6
			> 158
		)
	):
		font_size -= 1
	money_label.add_theme_font_size_override("font_size", font_size)
	var price_label: Label = $SlotHint/Price
	var price: int = session.current_draw_price()
	var affordable: bool = session.money >= price
	price_label.text = AMOUNTS.format_gold(price) + " G"
	$SlotHint.add_theme_stylebox_override(
		"panel", get_theme_stylebox("panel" if affordable else "disabled", "PricePlate")
	)
	price_label.add_theme_color_override(
		"font_color", get_theme_color("accent_color" if affordable else "secondary_color", "Label")
	)
	var price_font: Font = price_label.get_theme_font("font")
	var price_font_size: int = 28
	while (
		price_font_size > 18
		and (
			(
				(
					price_font
					. get_string_size(
						price_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, price_font_size
					)
					. x
				)
				+ 6
			)
			> price_label.size.x
		)
	):
		price_font_size -= 1
	price_label.add_theme_font_size_override("font_size", price_font_size)
	earn_button.text = ""
	_refresh_search_glow()
	can_count_label.text = "빈캔 " + AMOUNTS.format_amount(session.cans)
	_refresh_quest_panel()
	shop_button.disabled = (
		result_overlay.visible or info_overlay.visible
		or session.purchasable_drinks().is_empty()
	)
	earn_button.disabled = result_overlay.visible or info_overlay.visible
	$Navigation/AbilityButton.disabled = result_overlay.visible
	shop_button.tooltip_text = ""


func _on_menu_button_pressed() -> void:
	pause_menu.set_open(true)


func _refresh_quest_panel() -> void:
	var minimized: bool = session.quest_reward_claimed and session.can_quest_reward_claimed
	var can_quest: bool = session.quest_reward_claimed
	var target: int = session.CAN_QUEST_TARGET if can_quest else session.QUEST_TARGET
	var progress: int = (
		mini(session.collected_cans(), target) if can_quest else session.quest_clicks
	)
	var reward: int = session.CAN_QUEST_REWARD if can_quest else session.QUEST_REWARD
	$QuestPanel/QuestText.text = "빈캔을 5개 모으시오" if can_quest else "동전 10번 발견하기"
	$QuestPanel/QuestBar.max_value = target
	$QuestPanel/QuestBar.value = progress
	$QuestPanel/RewardHint.text = "보상 ¥%d" % reward
	quest_progress.text = "%d / %d" % [progress, target]
	quest_complete_button.disabled = minimized or progress < target
	quest_complete_button.text = "보상 받기 · ¥%d" % reward
	$QuestPanel/Divider.visible = not minimized
	$QuestPanel/QuestText.visible = not minimized
	$QuestPanel/QuestBar.visible = not minimized
	$QuestPanel/RewardHint.visible = not minimized and progress < target
	quest_progress.visible = not minimized
	quest_complete_button.visible = not minimized and progress >= target
	quest_title.text = "퀘스트 모두 완료 ✓" if minimized else ("빈캔 수집" if can_quest else "첫 수집 목표")
	var completed_width := maxf(234.0, quest_title.get_minimum_size().x + 36.0)
	var completed_height := maxf(64.0, quest_title.get_minimum_size().y + 32.0)
	quest_panel.offset_left = -28.0 - completed_width if minimized else -290.0
	quest_panel.offset_top = $WalletPanel.offset_top
	quest_panel.offset_bottom = quest_panel.offset_top + (completed_height if minimized else 178.0)
	quest_title.position.y = 12.0
	quest_title.size.x = quest_panel.size.x - 36.0


func _on_ability_button_pressed() -> void:
	_on_skill_button_pressed()


func _on_skill_button_pressed() -> void:
	if get_tree().paused or result_overlay.visible:
		return
	_set_info_layout(true)
	$InfoOverlay/Card/Title.text = "음료수 추가"
	$InfoOverlay/Card/Catalog.hide()
	$InfoOverlay/Card/Summary.hide()
	$InfoOverlay/Card/SkillTree.show()
	$InfoOverlay/Card/SkillTree.reset_selection()
	_refresh_skill_tree()
	_open_info()


func _refresh_skill_tree() -> void:
	var active: Array[int] = []
	var collected: Dictionary = {}
	var effects: Dictionary = {}
	var enhancements: Dictionary = {}
	for i in range(DRINK_DATA.size()):
		collected[i] = session.drink_count(i)
		effects[i] = _drink_cumulative_text(i)
		enhancements[i] = session.enhancement_count(i)
	for i in range(2, DRINK_DATA.size()):
		if session.drink_unlocked(i):
			active.append(i)
	var summary := (
		"발견 보너스 +%d Gold\n수색 %d회 · 더블 클릭 %.0f%%\n꽝 %.0f%% · 골드 2배 %.0f%%\n"
		+ "수색 피버 %.0f초 / 펀치 %.0f초\n황금 %.1f%% · 주차장 %s"
	)
	summary = summary % [
		session.coin_bonus(),
		session.clicks_required(),
		session.double_click_chance() * 100,
		session.miss_chance() * 100,
		session.double_reward_chance() * 100,
		session.search_fever_duration(),
		session.punch_fever_duration(),
		session.golden_chance() * 100,
		"해금" if session.parking_unlocked() else "잠김",
	]
	$InfoOverlay/Card/SkillTree.update_state(
		session.cans, active, collected, summary, effects, enhancements
	)


func _drink_cumulative_text(index: int) -> String:
	var text: String = ""
	match index:
		0, 1, 9:
			text = "누적 발견 골드 +%d Gold" % session.drink_coin_bonus(index)
		2, 4:
			text = "상위 골드 확률 강화 %d/5" % session.enhancement_count(index)
		3:
			text = "현재 수색 %d회 · 비타민 최대 −2회" % session.clicks_required()
		5:
			text = "펀치 피버 %.0f초" % session.punch_fever_duration()
		6:
			text = "획득 시 수색 피버 %.0f초 · 반복 등장" % session.search_fever_duration()
		7:
			return "주차장 해금 완료 · 추첨 제외" if session.parking_unlocked() else "획득 시 주차장 해금"
		8:
			text = "클릭 2회 인정 확률 %.0f%%" % (session.double_click_chance() * 100)
		10:
			text = "골드 2배 확률 %.0f%%" % (session.double_reward_chance() * 100)
		11:
			text = "현재 꽝 확률 %.0f%%" % (session.miss_chance() * 100)
		12:
			text = "수색 피버 %.0f초" % session.search_fever_duration()
		13:
			text = "황금 등장 확률 %.1f%%" % (session.golden_chance() * 100)
		14:
			text = "획득 시 펀치 피버 %.0f초 · 반복 등장" % session.punch_fever_duration()
	if index not in [6, 14] and session.enhancement_complete(index):
		text += "\n최대 강화 · 추첨 제외"
	return text

func _set_info_layout(skill_mode: bool) -> void:
	var card: Panel = $InfoOverlay/Card
	info_overlay.color = (
		Color(16.0 / 255, 27.0 / 255, 41.0 / 255, 0.53)
		if skill_mode
		else Color(0.043, 0.067, 0.094, 0.84)
	)
	$InfoOverlay/Card/Title.visible = not skill_mode
	$InfoOverlay/Card/CloseButton.visible = not skill_mode
	if skill_mode:
		card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		card.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		$InfoOverlay/Card/SkillTree.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		card.position = (info_overlay.size - Vector2(560, 560)) * 0.5
		card.size = Vector2(560, 560)
		card.remove_theme_stylebox_override("panel")


func _on_unlock_ion_pressed() -> void:
	_on_unlock_drink_requested(2)


func _on_unlock_drink_requested(index: int) -> void:
	if get_tree().paused or not info_overlay.visible or not $InfoOverlay/Card/SkillTree.visible:
		return
	if not session.unlock(index):
		return
	_refresh_ui()
	_refresh_skill_tree()
	_save_progress()


func _open_info() -> void:
	info_overlay.show()
	_refresh_ui()
	if $InfoOverlay/Card/SkillTree.visible:
		return
	else:
		$InfoOverlay/Card/CloseButton.grab_focus()


func _on_info_close_pressed() -> void:
	info_overlay.hide()
	_refresh_ui()
	$Navigation/AbilityButton.grab_focus()


func _finish_action(message: String) -> void:
	feedback_label.text = message
	_refresh_ui()
	_save_progress()


func _save_progress() -> void:
	last_save_error = ERR_UNCONFIGURED
	save_requested.emit()
	if last_save_error != OK:
		feedback_label.text += " (저장 실패)"


func _on_pause_save_requested() -> void:
	_save_progress()
	pause_menu.status.text = "저장했습니다." if last_save_error == OK else "저장하지 못했습니다. 다시 시도해주세요."


func _on_pause_quit_requested() -> void:
	_save_progress()
	if last_save_error != OK:
		pause_menu.status.text = "저장하지 못해 종료하지 않았습니다. 다시 시도해주세요."
		return
	get_tree().paused = false
	quit_requested.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		_save_progress()


func _exit_tree() -> void:
	var cursor := get_node_or_null("/root/CursorTheme")
	if cursor != null:
		cursor.call("set_punch_mode", false)


func _on_escape_requested() -> void:
	if not pause_menu.overlay.visible and info_overlay.visible:
		_on_info_close_pressed()
	else:
		pause_menu.set_open(not pause_menu.overlay.visible)
