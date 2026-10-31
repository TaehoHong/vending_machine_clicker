extends Control

signal save_requested
signal quit_requested

const SESSION = preload("res://src/game/game_session.gd")
const AMOUNTS = preload("res://src/shared/formatting/amount_format.gd")
const DRINK_DATA = preload("res://src/data/drink_catalog.gd").DATA
const DESIGN = preload("res://src/shared/ui/design_view.gd")
const FEVER_COIN_SCALE: float = 2.5

var session: SESSION = SESSION.new()
var last_save_error: Error = OK

var _purchase_effects: Dictionary = {}
var display_products: Dictionary[int, Control] = {}
var display_shadows: Dictionary[int, Control] = {}
var facilities_screen: Control
var quest_screen: Control
var quest_toast: Control
var quest_button: Button
var facility_world: Control
var ability_toast: Control
var wallet_tooltip: Control
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

@onready var money_label: Label = DESIGN.shape($Design, "Amount / 골드 / 숫자")
@onready var price_label: Label = DESIGN.shape($Design, "Amount")
@onready var earn_button: Button = $EarnButton
@onready var search_glow: TextureRect = $SearchGlow
@onready var can_count_label: Label = DESIGN.shape($Design, "Amount / 빈캔 / 숫자")
@onready var info_overlay: ColorRect = $InfoOverlay
@onready var shop_button: Button = $CoinSlotButton
@onready var result_overlay: ColorRect = $ResultOverlay
@onready var result_title: Label = $ResultOverlay/Card/Margin/Contents/DrinkName
@onready var result_art: TextureRect = $ResultOverlay/Card/Margin/Contents/DrinkArt
@onready var result_effect: RichTextLabel = $ResultOverlay/Card/Margin/Contents/Effect
@onready var close_button: Button = $ResultOverlay/Card/Margin/Contents/CloseButton
@onready var feedback_label: Label = $FeedbackLabel
@onready var pause_menu: CanvasLayer = $PauseMenu


func _ready() -> void:
	_setup_design()
	_setup_drink_catalog()
	pause_menu.escape_requested.connect(_on_escape_requested)
	$InfoOverlay/Card/SkillTree.close_requested.connect(_on_info_close_pressed)
	ability_toast = preload("res://src/features/play/effects/ability_toast.gd").new()
	ability_toast.name = "AbilityToast"
	add_child(ability_toast)
	move_child(ability_toast, result_overlay.get_index())
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
	_setup_facility_world()
	_setup_quests()
	if session.collect_facility_gold() > 0:
		_save_progress()
	_refresh_ui()


func _process(delta: float) -> void:
	facility_world.advance(delta)
	var blocked: bool = (
		result_overlay.visible or info_overlay.visible or is_instance_valid(facilities_screen)
		or is_instance_valid(quest_screen)
	)
	quest_toast.advance(delta, blocked)
	search_hint.set(
		"blocked",
		blocked or session.search_fever_remaining > 0 or session.punch_fever_remaining > 0
	)
	var search_was_active: bool = session.search_fever_remaining > 0
	var punch_was_active: bool = session.punch_fever_remaining > 0
	var purchase_was_delayed: bool = session.punch_purchase_delay > 0
	session.advance(delta, blocked)
	if search_was_active and session.search_fever_remaining == 0:
		_refresh_ui()
	if punch_was_active and session.punch_fever_remaining == 0:
		_restore_machine_position()
		_refresh_ui()
	if purchase_was_delayed and session.punch_purchase_delay == 0:
		_refresh_ui()
	search_fever_fx.set("simultaneous", session.punch_fever_remaining > 0)
	search_fever_fx.call(
		"update_state",
		session.search_fever_remaining,
		session.search_fever_total,
		blocked
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
		or info_overlay.visible or is_instance_valid(facilities_screen)
		or is_instance_valid(quest_screen)
		or session.punch_fever_remaining <= 0
	):
		return
	if not punch_button.get_rect().has_point(last_punch_point):
		last_punch_point = get_local_mouse_position()
		if not punch_button.get_rect().has_point(last_punch_point):
			last_punch_point = punch_button.get_rect().get_center()
	$PunchHit.play()
	punch_fever_fx.call("add_hit", last_punch_point)
	_restore_machine_position()
	machine_hit_tween = $VendingMachine.create_tween()
	machine_hit_tween.tween_property(
		$VendingMachine, "position", machine_home + (
			Vector2.ZERO if get_node("/root/Preferences").values.reduce_motion
			else Vector2(randf_range(-7, 7), -4)
		), 0.035
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
		$MissResult.play()
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
		or info_overlay.visible or is_instance_valid(facilities_screen)
		or is_instance_valid(quest_screen)
	):
		return
	search_hint.call("notify_search_click")
	$SearchClick.play()
	var earned: int = session.search()
	if earned < 0:
		_refresh_ui()
		return
	if earned == 0:
		$MissResult.play()
		_show_empty_search()
	else:
		$SearchCoin.play()
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


func _claim_quest(quest_id: String) -> void:
	if (
		get_tree().paused or result_overlay.visible or info_overlay.visible
		or is_instance_valid(facilities_screen)
	):
		return
	var quest: Dictionary = session.quest_status(quest_id)
	if not session.claim_quest(quest_id):
		return
	_finish_action("")
	if is_instance_valid(quest_screen):
		quest_screen.refresh()
	var effect := preload("res://src/features/quests/reward_fx.gd").new()
	effect.name = "QuestRewardFX"
	effect.z_index = 110
	add_child(effect)
	effect.start(
		Vector2(576, 48.8), money_label, quest.reward,
		get_node("/root/Preferences").values.reduce_motion
	)


func _setup_coin_slot() -> void:
	# 비활성화 상태에도 기본 테마의 사각형이 나타나지 않도록 모두 투명 처리.
	for state in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		shop_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	_position_coin_slot()


func _position_coin_slot() -> void:
	var factor := minf(size.x / 1152.0, size.y / 648.0)
	var origin := (size - Vector2(1152, 648) * factor) * 0.5
	DESIGN.fit($Design, size)
	var machine: Control = $VendingMachine
	machine.position = origin + Vector2(427.392, 68.04) * factor
	machine.scale = Vector2.ONE * factor
	machine_home = machine.position
	punch_button.position = origin + Vector2(459, 110) * factor
	punch_button.size = Vector2(254, 356) * factor
	shop_button.position = origin + Vector2(459, 110) * factor
	shop_button.size = Vector2(254, 270) * factor
	# 투명 여백을 제외한 자판기 높이의 하단 2%부터 수색할 수 있다.
	earn_button.position = origin + Vector2(458.5, 458.54) * factor
	earn_button.size = Vector2(276.48, 82.54) * factor
	search_glow.position = origin + Vector2(458.5, 463) * factor
	search_glow.size = Vector2(276.48, 78) * factor
	search_hint.position = origin + Vector2(575.74, 478) * factor
	search_hint.scale = Vector2.ONE * factor
	search_fever_fx.size = size
	punch_fever_fx.size = size
	ability_toast.position = origin + Vector2(319, 100) * factor
	ability_toast.scale = Vector2.ONE * factor
	$Navigation.position = Vector2.ZERO
	$Navigation.scale = Vector2.ONE
	# 공통 프레임의 투명 여백 4.8px를 제외한 화면 가장자리를 16px에 맞춘다.
	$Navigation/AbilityButton.position = origin + Vector2(11.2, 582.4) * factor
	$Navigation/AbilityButton.scale = Vector2.ONE * factor
	$MenuButton.position = origin + Vector2(1086.4, 582.4) * factor
	$MenuButton.scale = Vector2.ONE * factor
	_layout_quests()
	for entry: Dictionary in _purchase_effects.values():
		_position_purchase_effect(entry.coin, entry.drink)


func _position_purchase_effect(coin: Control, drink: Control) -> void:
	var machine: Control = $VendingMachine
	coin.set("target", coin_insertion_target())
	drink.set("outlet", machine.position + Vector2(146, 338) * machine.scale)
	drink.set("destination", ability_receipt_position())


func ability_receipt_position() -> Vector2:
	var button: Button = $Navigation/AbilityButton
	return (
		get_global_transform().affine_inverse()
		* (button.get_global_transform() * (button.size * 0.5))
	)


func _show_acquired_ability() -> void:
	var button: Button = $Navigation/AbilityButton
	if is_instance_valid(ability_receipt_tween):
		ability_receipt_tween.kill()
	button.modulate = Color(1.5, 1.5, 1.5)
	ability_receipt_tween = button.create_tween()
	ability_receipt_tween.tween_property(button, "modulate", Color.WHITE, 0.35)


func coin_insertion_target() -> Vector2:
	var machine: Control = $VendingMachine
	return machine.position + Vector2(247, 188.4) * machine.scale


func _on_shop_button_pressed() -> void:
	if session.punch_fever_remaining > 0:
		_on_punch_button_pressed()
		return
	if session.punch_purchase_delay > 0:
		return
	if (
		get_tree().paused
		or result_overlay.visible
		or info_overlay.visible or is_instance_valid(facilities_screen)
		or is_instance_valid(quest_screen)
	):
		return
	var price: int = session.current_draw_price()
	if session.money < price:
		ability_toast.call("present_shortage", price, price - session.money)
		return
	if not session.purchase():
		return
	# 차감과 획득을 함께 즉시 저장해 애니메이션 중 종료해도 음료를 잃지 않는다.
	_finish_action("")
	_start_purchase_effect(session.purchase_count, session.last_drink)


func _start_purchase_effect(purchase_id: int, drink_index: int) -> void:
	var coin: Control = preload("res://src/features/play/effects/coin_insert_fx.gd").new()
	var drink: Control = preload("res://src/features/play/effects/drink_dispense_fx.gd").new()
	for effect: Control in [coin, drink]:
		effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(effect)
		move_child(effect, info_overlay.get_index())
	_position_purchase_effect(coin, drink)
	coin.call("advance", 0.0)
	var animation: Tween = create_tween()
	_purchase_effects[purchase_id] = {"coin": coin, "drink": drink, "animation": animation}
	animation.tween_method(Callable(coin, "advance"), 0.0, 1.02, 1.02)
	animation.tween_callback(coin.hide)
	animation.tween_callback(
		func() -> void:
			drink.call("begin", load(DRINK_DATA[drink_index].asset), Color(DRINK_DATA[drink_index].color))
	)
	animation.tween_method(Callable(drink, "advance"), 0.0, 1.32, 1.32)
	animation.tween_callback(_finish_purchase_effect.bind(purchase_id))


func _finish_purchase_effect(purchase_id: int) -> void:
	if not _purchase_effects.has(purchase_id):
		return
	var entry: Dictionary = _purchase_effects[purchase_id]
	entry.coin.hide()
	entry.drink.hide()
	entry.coin.queue_free()
	entry.drink.queue_free()
	_purchase_effects.erase(purchase_id)
	if session.finish_purchase(purchase_id):
		_show_acquired_ability()
	_process(0)
	_refresh_ui()


func _refresh_vending_display() -> void:
	for index in DRINK_DATA.size():
		var slot: int = DRINK_DATA[index].display_slot
		display_products[slot].visible = session.drink_unlocked(index)
		display_shadows[slot].visible = session.drink_unlocked(index)


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
	money_label.text = AMOUNTS.format_gold(session.money)
	money_label.tooltip_text = ""
	DESIGN.fit_text(money_label, 80)
	var price: int = session.current_draw_price()
	price_label.text = AMOUNTS.format_gold(price)
	DESIGN.fit_text(price_label, 56)
	price_label.tooltip_text = "%s Gold" % AMOUNTS.format_amount(price)

	earn_button.text = ""
	_refresh_search_glow()
	can_count_label.text = AMOUNTS.format_gold(session.cans)
	can_count_label.tooltip_text = ""
	DESIGN.fit_text(can_count_label, 36)
	if wallet_tooltip.visible:
		_show_wallet_tooltip(wallet_tooltip.get_meta("currency", "gold"))
	_refresh_quests()
	shop_button.disabled = (
		result_overlay.visible or info_overlay.visible or is_instance_valid(facilities_screen)
		or is_instance_valid(quest_screen)
		or session.purchasable_drinks().is_empty()
		or session.punch_purchase_delay > 0
	)
	earn_button.disabled = (
		result_overlay.visible or info_overlay.visible or is_instance_valid(facilities_screen)
		or is_instance_valid(quest_screen)
	)
	$Navigation/AbilityButton.disabled = result_overlay.visible
	shop_button.tooltip_text = ""


func _on_menu_button_pressed() -> void:
	if not is_instance_valid(quest_screen):
		pause_menu.set_open(true)


func _setup_quests() -> void:
	quest_button = DESIGN.action($QuestHud, "Action / Open Quests", _open_quests)
	quest_button.accessibility_name = "퀘스트"
	quest_button.tooltip_text = "퀘스트"
	quest_toast = preload("res://src/features/quests/toast_design.tscn").instantiate()
	quest_toast.session = session
	add_child(quest_toast)
	quest_toast.claim_requested.connect(_claim_quest)
	_layout_quests()


func _layout_quests() -> void:
	var factor := minf(size.x / 1152.0, size.y / 648.0)
	var origin := (size - Vector2(1152, 648) * factor) * 0.5
	$QuestHud.position = origin + Vector2(1086.4, 11.2) * factor
	$QuestHud.scale = Vector2.ONE * 0.8 * factor
	if is_instance_valid(quest_toast):
		quest_toast.position = origin + Vector2(412.8, 20) * factor
		quest_toast.scale = Vector2.ONE * 0.6 * factor


func _refresh_quests() -> void:
	if not is_instance_valid(quest_toast):
		return
	var ready: bool = false
	for id: String in session.QUEST_IDS:
		ready = ready or session.quest_status(id).ready
	DESIGN.shape($QuestHud, "Badge / Claimable").visible = ready
	quest_toast.sync()
	_layout_quests()


func _open_quests() -> void:
	if (
		get_tree().paused or result_overlay.visible or info_overlay.visible
		or is_instance_valid(facilities_screen) or is_instance_valid(quest_screen)
	):
		return
	quest_button.grab_focus()
	quest_screen = preload("res://src/features/quests/quest_screen.tscn").instantiate()
	add_child(quest_screen)
	quest_screen.claim_requested.connect(_claim_quest)
	quest_screen.closed.connect(func() -> void:
		quest_screen = null
		_refresh_ui()
	)
	quest_screen.open(session)
	_refresh_ui()


func _on_ability_button_pressed() -> void:
	_on_skill_button_pressed()


func _on_skill_button_pressed() -> void:
	if get_tree().paused or result_overlay.visible or is_instance_valid(quest_screen):
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
	pause_menu.show_save_status(
		"저장했습니다." if last_save_error == OK else "저장하지 못했습니다. 다시 시도해주세요.",
		last_save_error != OK
	)


func _on_pause_quit_requested() -> void:
	_save_progress()
	if last_save_error != OK:
		pause_menu.show_save_status("저장하지 못해 종료하지 않았습니다. 다시 시도해주세요.", true)
		return
	get_tree().paused = false
	quit_requested.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		_save_progress()


func _exit_tree() -> void:
	for entry: Dictionary in _purchase_effects.values():
		entry.animation.kill()
	_purchase_effects.clear()
	var cursor := get_node_or_null("/root/CursorTheme")
	if cursor != null:
		cursor.call("set_punch_mode", false)


func _on_escape_requested() -> void:
	if is_instance_valid(quest_screen):
		quest_screen.close()
		return
	if is_instance_valid(facilities_screen):
		facilities_screen.go_back()
		return
	if not pause_menu.overlay.visible and info_overlay.visible:
		_on_info_close_pressed()
	else:
		pause_menu.set_open(not pause_menu.overlay.visible)


func _setup_design() -> void:
	for child: Control in $VendingMachine.get_children():
		var source_name: String = child.get_meta("penpot_name", "")
		if source_name.begins_with("진열 슬롯 /"):
			var place: String = source_name.get_slice(" / ", 1)
			var slot: int = (int(place.left(1)) - 1) * 5 + int(place.substr(3, 1)) - 1
			display_products[slot] = child
		elif source_name.begins_with("접지 /"):
			display_shadows[int(source_name.get_slice(" / ", 1)) - 1] = child
	for entry in [
		[$MenuButton, "HUD / 메뉴 / normal", _on_menu_button_pressed],
		[$Navigation/AbilityButton, "HUD / 능력 / normal", _on_ability_button_pressed],
	]:
		var previous: Button = entry[0]
		var artwork := DESIGN.shape($Design, entry[1])
		var button := DESIGN.action($Design, entry[1], entry[2])
		button.reparent(previous.get_parent(), false)
		var button_name: String = previous.name
		previous.get_parent().remove_child(previous)
		previous.queue_free()
		button.name = button_name
		artwork.reparent(button, false)
		artwork.position = Vector2.ZERO
	var price_panel := DESIGN.shape($Design, "HUD / 가격 / 기본")
	price_panel.reparent($VendingMachine, false)
	price_panel.position = Vector2(220.25, 143.51)
	$MenuButton.set_anchors_preset(Control.PRESET_TOP_LEFT)
	$Navigation.set_anchors_preset(Control.PRESET_TOP_LEFT)
	$Navigation.mouse_filter = Control.MOUSE_FILTER_IGNORE
	DESIGN.action($Design, "UI / 버튼 / 시설", _open_facilities)
	wallet_tooltip = preload("res://src/features/play/wallet_tooltip_design.tscn").instantiate()
	wallet_tooltip.name = "WalletTooltip"
	wallet_tooltip.position = Vector2(16, 68)
	$Design.add_child(wallet_tooltip)
	wallet_tooltip.hide()
	for entry in [[money_label, "gold"], [can_count_label, "cans"]]:
		var label: Label = entry[0]
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		label.mouse_entered.connect(_show_wallet_tooltip.bind(entry[1]))
		label.mouse_exited.connect(wallet_tooltip.hide)


func _show_wallet_tooltip(currency: String) -> void:
	wallet_tooltip.set_meta("currency", currency)
	var caption: Label = DESIGN.shape(wallet_tooltip, "Text / Caption")
	var amount: Label = DESIGN.shape(wallet_tooltip, "Text / Amount")
	caption.text = "빈캔" if currency == "cans" else "보유 골드"
	amount.text = (
		"%d개" % session.cans if currency == "cans"
		else "%s 골드" % AMOUNTS.format_amount(session.money)
	)
	wallet_tooltip.show()


func _open_facilities() -> void:
	if (
		get_tree().paused or info_overlay.visible or is_instance_valid(facilities_screen)
		or is_instance_valid(quest_screen)
	):
		return
	facilities_screen = preload("res://src/features/facilities/facilities_screen.tscn").instantiate()
	add_child(facilities_screen)
	facilities_screen.changed.connect(_on_facilities_changed)
	facilities_screen.closed.connect(
		func() -> void:
			facilities_screen = null
			_refresh_ui()
	)
	facilities_screen.open(session)
	_refresh_ui()


func _on_facilities_changed() -> void:
	facility_world.refresh()
	_refresh_ui()
	_save_progress()


func _setup_facility_world() -> void:
	facility_world = preload("res://src/features/facilities/world_design.tscn").instantiate()
	facility_world.session = session
	facility_world.name = "FacilityWorld"
	add_child(facility_world)
	move_child(facility_world, $VendingMachine.get_index() + 1)
	facility_world.changed.connect(_on_facilities_changed)
