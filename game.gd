extends Control

# 임시 밸런스 값. 확정 기획이 아니며 플레이 테스트 후 조정한다.
const CLICKS_PER_REWARD: int = 10
const QUEST_TARGET: int = 10
const QUEST_REWARD: int = 5000
const CAN_QUEST_TARGET: int = 5
# 보상이 미정인 새 퀘스트에는 기존과 같은 임시 보상을 사용한다.
const CAN_QUEST_REWARD: int = 100
const DRAW_PRICE: int = 100
const ION_UNLOCK_COST: int = 5
const DRINK_DATA = preload("res://ui/drink_catalog.gd").DATA
const CANS_PER_BONUS: int = 5
const MAX_MACHINE_LEVEL: int = 4
const FEVER_COIN_SCALE: float = 2.5
const COINS: Array[int] = [1, 5, 10, 50, 100, 500, 1000, 5000]
var save_path: String = "user://progress.cfg"
var start_new_game: bool = false
var last_save_error: Error = OK

var money: int = 0
var click_stack: int = 0
var quest_clicks: int = 0
var quest_reward_claimed: bool = false
var can_quest_reward_claimed: bool = false
var drinks: int = 0
var purchase_count: int = 0
var water_count: int = 0
var green_tea_count: int = 0
var ion_count: int = 0
var ion_unlocked: bool = false
var extra_counts: Dictionary = {}
var unlocked_drinks: Array[int] = []
var last_drink: int = 0
var cans: int = 0
var machine_level: int = 0
var inserting_coin: bool = false
var coin_tween: Tween
var coin_insert_fx: Control
var drink_dispense_fx: Control
var ability_toast: Control
var ability_receipt_tween: Tween
var search_glow_tween: Tween
var search_hint: Control
var search_fever_fx: Control
var search_fever_remaining: float = 0.0
var search_fever_total: float = 10.0
var search_fever_pending: bool = false
var punch_fever_remaining: float = 0.0
var punch_fever_total: float = 5.0
var punch_fever_pending: bool = false
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
	if start_new_game:
		_save_progress()
	else:
		_load_progress()
	_setup_drink_catalog()
	$InfoOverlay/Card/SkillTree.close_requested.connect(_on_info_close_pressed)
	ability_toast = preload("res://ui/ability_toast.gd").new()
	ability_toast.name = "AbilityToast"
	add_child(ability_toast)
	move_child(ability_toast, result_overlay.get_index())
	drink_dispense_fx = preload("res://ui/drink_dispense_fx.gd").new()
	drink_dispense_fx.name = "DrinkDispenseFX"
	add_child(drink_dispense_fx)
	move_child(drink_dispense_fx, result_overlay.get_index())
	search_hint = preload("res://ui/search_hint.gd").new()
	search_hint.name = "SearchHint"
	add_child(search_hint)
	move_child(search_hint, result_overlay.get_index())
	search_fever_fx = preload("res://ui/search_fever.gd").new()
	search_fever_fx.name = "SearchFeverFX"
	add_child(search_fever_fx)
	move_child(search_fever_fx, result_overlay.get_index())
	punch_fever_fx = preload("res://ui/punch_fever.gd").new()
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
	punch_button.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			last_punch_point = punch_button.position + event.position
	)
	punch_button.hide()
	_setup_coin_slot()
	_setup_search_area()
	resized.connect(_position_coin_slot)
	_refresh_ui()

func _process(delta: float) -> void:
	var blocked: bool = inserting_coin or result_overlay.visible or info_overlay.visible
	search_hint.set("blocked", blocked or search_fever_remaining > 0 or punch_fever_remaining > 0)
	if search_fever_remaining > 0 and not blocked:
		search_fever_remaining = maxf(0, search_fever_remaining - delta)
		if search_fever_remaining == 0:
			_refresh_ui()
	if punch_fever_remaining > 0 and not blocked:
		punch_fever_remaining = maxf(0, punch_fever_remaining - delta)
		if punch_fever_remaining == 0:
			_restore_machine_position()
	search_fever_fx.call("update_state", search_fever_remaining, search_fever_total, blocked or punch_fever_remaining > 0)
	punch_fever_fx.call("update_state", punch_fever_remaining, punch_fever_total, blocked)
	punch_button.visible = punch_fever_remaining > 0 and not blocked
	get_node("/root/CursorTheme").call("set_punch_mode", punch_fever_remaining > 0 and not blocked)

func punch_fever_duration() -> float:
	return 5.0 + mini(drink_count(5), 10)

func _start_punch_fever() -> void:
	punch_fever_total = punch_fever_duration()
	punch_fever_remaining = punch_fever_total
	_process(0)
	_refresh_ui()

func _restore_machine_position() -> void:
	if is_instance_valid(machine_hit_tween):
		machine_hit_tween.kill()
	$VendingMachine.position = machine_home
	$VendingMachine.modulate = Color.WHITE

func _on_punch_button_pressed() -> void:
	if get_tree().paused or inserting_coin or result_overlay.visible or info_overlay.visible or punch_fever_remaining <= 0:
		return
	if not punch_button.get_rect().has_point(last_punch_point):
		last_punch_point = get_local_mouse_position()
		if not punch_button.get_rect().has_point(last_punch_point):
			last_punch_point = punch_button.get_rect().get_center()
	punch_fever_fx.call("add_hit", last_punch_point)
	_restore_machine_position()
	machine_hit_tween = $VendingMachine.create_tween()
	machine_hit_tween.tween_property($VendingMachine, "position", machine_home + Vector2(randf_range(-7, 7), -4), 0.035)
	machine_hit_tween.parallel().tween_property($VendingMachine, "modulate", Color(1.45, 1.3, 1.2), 0.035)
	machine_hit_tween.tween_property($VendingMachine, "position", machine_home + Vector2(randf_range(-4, 4), 2), 0.045)
	machine_hit_tween.tween_property($VendingMachine, "position", machine_home, 0.08)
	machine_hit_tween.parallel().tween_property($VendingMachine, "modulate", Color.WHITE, 0.08)
	if _search_is_empty():
		_show_empty_search()
		_finish_action("")
		return
	var coin_index: int = 0
	while coin_index < 3 + machine_level and randf() < 0.22:
		coin_index += 1
	var earned: int = calculate_reward(COINS[coin_index]) * 3
	money += earned
	quest_clicks = mini(quest_clicks + 1, QUEST_TARGET)
	_show_coin_reward(earned)
	_finish_action("")

func search_fever_duration() -> float:
	return 10.0 + mini(drink_count(12), 10)

func _start_search_fever() -> void:
	search_fever_total = search_fever_duration()
	search_fever_remaining = search_fever_total
	_refresh_ui()

func clicks_required() -> int:
	var normal: int = maxi(3, CLICKS_PER_REWARD - water_count / 3 - drink_count(8) / 4)
	return maxi(1, normal - 5) if search_fever_remaining > 0 else normal

func _on_earn_button_pressed() -> void:
	if punch_fever_remaining > 0:
		_on_punch_button_pressed()
		return
	if get_tree().paused or inserting_coin or result_overlay.visible or info_overlay.visible:
		return
	search_hint.call("notify_search_click")
	if search_fever_remaining > 0:
		var point := get_local_mouse_position()
		if not earn_button.get_rect().has_point(point):
			point = earn_button.position + earn_button.size * Vector2(0.5, 0.35)
		search_fever_fx.call("add_click", point)
	click_stack = mini(click_stack + 1, clicks_required())
	if click_stack < clicks_required():
		_refresh_ui()
		return
	# 상위 자판기를 구매하면 등장 가능한 화폐가 한 단계씩 늘어난다.
	if _search_is_empty():
		click_stack = 0
		_show_empty_search()
		_finish_action("")
		return
	var coin_index: int = 0
	while coin_index < 3 + machine_level and randf() < 0.22:
		coin_index += 1
	var earned: int = calculate_reward(COINS[coin_index])
	click_stack = 0
	money += earned
	quest_clicks = mini(quest_clicks + 1, QUEST_TARGET)
	_show_coin_reward(earned)
	_finish_action("")

func _show_coin_reward(amount: int) -> void:
	_clear_search_popups("empty_search_popups")
	_show_search_coin(amount)
	var popup := Label.new()
	popup.name = "CoinRewardPopup"
	popup.text = "+%d" % amount
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.add_theme_font_override("font", preload("res://ui/fonts/Cafe24PROUP.ttf"))
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
	popup.texture = preload("res://ui/crying_icon.svg")
	popup.custom_minimum_size = Vector2(42, 42)
	popup.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	popup.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_animate_search_popup(popup, "empty_search_popups")

func _show_search_coin(amount: int) -> void:
	if search_fever_remaining <= 0 and punch_fever_remaining <= 0:
		_clear_search_popups("search_coin_effects")
	punch_coin_phase = randf()
	var counts: Array[int] = preload("res://ui/search_coin.gd").breakdown(amount)
	var total: int = counts[0] + counts[1] + counts[2] + counts[3]
	var index: int = 0
	for tier in range(counts.size() - 1, -1, -1):
		for _i in range(counts[tier]):
			_spawn_search_coin(tier, index, total)
			index += 1

func _spawn_search_coin(tier: int, index: int, total: int) -> void:
	var coin: Control = preload("res://ui/search_coin.gd").new()
	coin.set("tier", tier)
	coin.name = "FoundCoin"
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin.size = Vector2(26, 26)
	coin.pivot_offset = coin.size * 0.5
	coin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(coin)
	move_child(coin, result_overlay.get_index())
	coin.add_to_group("search_coin_effects")
	if punch_fever_remaining > 0:
		move_child(coin, punch_fever_fx.get_index())
	var lane := float(index) / maxf(1.0, total - 1.0)
	var start := search_glow.position + Vector2(search_glow.size.x * lerpf(0.25, 0.75, lane), 0) - coin.size * 0.5
	if punch_fever_remaining > 0:
		start = _punch_coin_origin(index, total) - coin.size * 0.5
	coin.position = start
	if punch_fever_remaining > 0:
		_animate_punch_coin(coin, start)
		return
	if search_fever_remaining > 0:
		_animate_fever_coin(coin, start, index, total)
		return
	var direction := -1.0 if index % 2 == 0 else 1.0
	var height := randf_range(22, 48)
	var distance := randf_range(45, 90)
	var motion := coin.create_tween()
	motion.tween_property(coin, "position", start + Vector2(direction * 12, -height), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	motion.tween_property(coin, "position", start + Vector2(direction * 28, 18), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	motion.tween_property(coin, "position", start + Vector2(direction * distance, 22), 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
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
	motion.tween_method(func(t: float) -> void:
		coin.position = start.lerp(landing, t) + Vector2(0, -4.0 * height * t * (1.0 - t))
	, 0.0, 1.0, lifetime)
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
	var direction := (start + coin.size * 0.5 - punch_button.get_rect().get_center()).normalized().rotated(randf_range(-0.25, 0.25))
	var end := start + direction * randf_range(160, 290) + Vector2(0, 55)
	end.x = clampf(end.x, 35, maxf(35, size.x - 61))
	end.y = clampf(end.y, 110, maxf(110, size.y - 55))
	var lifetime := randf_range(0.75, 1.0)
	var arc := randf_range(25, 65)
	var motion := coin.create_tween()
	motion.tween_method(func(t: float) -> void:
		coin.position = start.lerp(end, t) + Vector2(0, -sin(t * PI) * arc)
	, 0.0, 1.0, lifetime)
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
	if punch_fever_remaining > 0:
		origin = last_punch_point
	elif not earn_button.get_rect().has_point(origin):
		origin = earn_button.position + earn_button.size * 0.5
	popup.position = origin + Vector2(randf_range(-36, 36), -randf_range(28, 48)) - popup.size * 0.5
	popup.position.x = clampf(popup.position.x, 8, maxf(8, size.x - popup.size.x - 8))
	popup.scale = Vector2(0.55, 0.55)
	var start: Vector2 = popup.position
	var drift: float = randf_range(-24, 24)
	var motion := popup.create_tween()
	motion.tween_property(popup, "position", start + Vector2(drift * 0.4, -48), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	motion.tween_property(popup, "position", start + Vector2(drift, -92), 0.73).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	motion.tween_callback(popup.queue_free)
	var bounce := popup.create_tween()
	bounce.tween_property(popup, "scale", Vector2(1.2, 1.2), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	bounce.tween_property(popup, "scale", Vector2.ONE, 0.12)
	var fade := popup.create_tween()
	fade.tween_interval(0.3)
	fade.tween_property(popup, "modulate:a", 0.0, 0.65)

func _search_is_empty() -> bool:
	return randf() < miss_chance()

func _setup_search_area() -> void:
	# 본체와 다리가 빛을 가려, 자판기 안쪽 틈에서 새어 나오도록 배치한다.
	move_child(search_glow, $VendingMachine.get_index())
	# 모든 버튼 상태를 투명하게 두어 배경 위에 클릭 영역만 남긴다.
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		earn_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	search_glow.modulate.a = clampf(float(click_stack) / clicks_required(), 0.0, 1.0)
	search_glow.call("set_progress", search_glow.modulate.a)

func _refresh_search_glow() -> void:
	if search_glow_tween and search_glow_tween.is_valid():
		search_glow_tween.kill()
	var brightness: float = clampf(float(click_stack) / clicks_required(), 0.0, 1.0)
	if search_fever_remaining > 0:
		brightness = maxf(0.35, brightness)
	search_glow.call("set_progress", brightness)
	search_glow_tween = create_tween()
	search_glow_tween.tween_property(search_glow, "modulate:a", brightness, 0.18)

func _on_quest_complete_button_pressed() -> void:
	if get_tree().paused or inserting_coin or result_overlay.visible or info_overlay.visible:
		return
	if not quest_reward_claimed:
		if quest_clicks < QUEST_TARGET:
			return
		quest_reward_claimed = true
		money += QUEST_REWARD
		_finish_action("")
	elif not can_quest_reward_claimed:
		if collected_cans() < CAN_QUEST_TARGET:
			return
		can_quest_reward_claimed = true
		money += CAN_QUEST_REWARD
		_finish_action("")

func _setup_coin_slot() -> void:
	# 비활성화 상태에도 기본 테마의 사각형이 나타나지 않도록 모두 투명 처리.
	for state in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		shop_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	coin_token.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	coin_token.get_node("Symbol").hide()
	coin_insert_fx = preload("res://ui/coin_insert_fx.gd").new()
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
	search_hint.position = Vector2(earn_button.position.x + earn_button.size.x * 0.5 - search_hint.size.x * 0.5, earn_button.position.y + earn_button.size.y * 0.5)
	search_fever_fx.size = size
	search_fever_fx.set("source", earn_button.position + earn_button.size * Vector2(0.5, 0.43))
	var slot_target := coin_insertion_target()
	if is_instance_valid(coin_insert_fx):
		coin_insert_fx.set("target", slot_target)
	$SlotHint.position = slot_target + Vector2(61, -29)
	$SlotHint.position.x = minf($SlotHint.position.x, size.x - $SlotHint.size.x - 12)
	ability_toast.position = Vector2((size.x - ability_toast.size.x) * 0.5, 100)
	drink_dispense_fx.set("outlet", machine.position + Vector2(490, 1210) * (machine.size.x / 1024.0))
	drink_dispense_fx.set("destination", ability_receipt_position())

func ability_receipt_position() -> Vector2:
	var button: Button = $Navigation/AbilityButton
	return get_global_transform().affine_inverse() * (button.get_global_transform() * (button.size * 0.5))

func _show_acquired_ability() -> void:
	var data: Dictionary = DRINK_DATA[last_drink]
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
	if punch_fever_remaining > 0:
		_on_punch_button_pressed()
		return
	if get_tree().paused or inserting_coin or result_overlay.visible or info_overlay.visible:
		return
	var price: int = current_draw_price()
	if money < price:
		feedback_label.text = "음료 뽑기에는 %s Gold가 필요합니다. (%s Gold 부족)" % [_format_amount(price), _format_amount(price - money)]
		return
	inserting_coin = true
	money -= price
	purchase_count += 1
	last_drink = _roll_drink()
	_apply_drink(last_drink)
	search_fever_pending = last_drink == 6
	punch_fever_pending = last_drink == 14
	# 차감과 획득을 함께 즉시 저장해 애니메이션 중 종료해도 음료를 잃지 않는다.
	_finish_action("")
	shop_button.disabled = true
	coin_token.position = Vector2.ZERO
	coin_token.scale = Vector2.ONE
	coin_token.modulate = Color.WHITE
	coin_insert_fx.set("target", coin_insertion_target())
	coin_insert_fx.call("advance", 0.0)
	coin_token.show()
	coin_tween = create_tween()
	coin_tween.tween_method(Callable(coin_insert_fx, "advance"), 0.0, 1.02, 1.02)
	coin_tween.tween_callback(coin_token.hide)
	coin_tween.tween_callback(func() -> void:
		drink_dispense_fx.call("begin", load(DRINK_DATA[last_drink].asset), Color(DRINK_DATA[last_drink].color))
	)
	coin_tween.tween_method(Callable(drink_dispense_fx, "advance"), 0.0, 1.32, 1.32)
	coin_tween.tween_callback(func() -> void:
		drink_dispense_fx.hide()
		_show_acquired_ability()
	)
	await coin_tween.finished
	inserting_coin = false
	if search_fever_pending:
		search_fever_pending = false
		_start_search_fever()
	if punch_fever_pending:
		punch_fever_pending = false
		_start_punch_fever()
	feedback_label.text = ""
	_refresh_ui()

func _roll_drink() -> int:
	var pool := purchasable_drinks()
	return pool[randi_range(0,pool.size()-1)]

func current_draw_price() -> int:
	# 원래 가격에 복리를 적용하고 결제 금액만 올림해 반올림 오차의 누적을 피한다.
	var price: float = DRAW_PRICE * pow(1.05, purchase_count)
	if not is_finite(price) or price >= 9.0e18:
		return 9000000000000000000
	return ceili(price - 0.00000001)

func purchasable_drinks() -> Array[int]:
	var pool: Array[int] = []
	for index in range(DRINK_DATA.size()):
		if drink_unlocked(index):
			pool.append(index)
	return pool

func _refresh_vending_display() -> void:
	var slots: int = 0
	for index in purchasable_drinks():
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

func _apply_drink(drink_index: int) -> void:
	drinks += 1
	cans += 1
	if drink_index == 0:
		water_count += 1
	elif drink_index == 1:
		green_tea_count += 1
	elif drink_index == 2:
		ion_count += 1
	else:
		extra_counts[drink_index] = drink_count(drink_index) + 1

func collected_cans() -> int:
	return maxi(cans, drinks)

func coin_bonus() -> int:
	return collected_cans() / CANS_PER_BONUS + green_tea_count + ion_count * 2 + drink_count(4) * 3 + drink_count(6) * 5

func drink_count(index: int) -> int:
	match index:
		0: return water_count
		1: return green_tea_count
		2: return ion_count
	return int(extra_counts.get(index,0))

func drink_unlocked(index: int) -> bool:
	return index >= 0 and index < DRINK_DATA.size() and (index < 2 or (ion_unlocked if index == 2 else unlocked_drinks.has(index)))

func miss_chance() -> float:
	return maxf(0.02,0.15-drink_count(3)*0.005)

func reward_multiplier() -> float:
	return 1.0+drink_count(5)*0.01+drink_count(7)*0.02

func calculate_reward(base_amount: int) -> int:
	var normal: int = maxi(1,floori((base_amount+coin_bonus())*reward_multiplier()))
	return normal * 2 if search_fever_remaining > 0 else normal

func _update_result() -> void:
	var data: Dictionary = DRINK_DATA[last_drink]
	result_title.text = "%s 획득!" % data.name
	result_art.texture = load(data.asset)
	$ResultOverlay/Card/Margin/Contents/Halo.modulate = Color(data.color)
	var effects: Array[String] = ["수색 숙련도 +1", "동전 발견 금액 +1 Gold", "동전 발견 금액 +2 Gold", "꽝 확률 -0.5%p", "동전 발견 금액 +3 Gold", "최종 발견 금액 +1%", "동전 발견 금액 +5 Gold", "최종 발견 금액 +2%", "수색 숙련도 +1"]
	if last_drink == 6:
		effects[6] = "수색 피버! 창을 닫으면 시작"
	var headline: String = effects[last_drink] if last_drink < effects.size() else "새 음료 수집 · 빈캔 +1"
	result_effect.text = "[center][font_size=21][color=%s]%s[/color][/font_size]\n[color=#A6B3BF]%s\n빈캔 +1[/color][/center]" % [data.color,headline,data.effect]

func _on_result_close_pressed() -> void:
	result_overlay.hide()
	if search_fever_pending:
		search_fever_pending = false
		_start_search_fever()
	_refresh_ui()
	shop_button.grab_focus()

func _refresh_ui() -> void:
	_refresh_vending_display()
	money_label.text = _format_gold(money) + " Gold"
	money_label.tooltip_text = "보유 골드: %s Gold" % _format_amount(money)
	var font: Font = money_label.get_theme_font("font")
	var font_size: int = 28
	while font_size > 18 and font.get_string_size(money_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 6 > 158:
		font_size -= 1
	money_label.add_theme_font_size_override("font_size", font_size)
	var price_label: Label = $SlotHint/Price
	price_label.text = _format_gold(current_draw_price()) + "G"
	var price_font: Font = price_label.get_theme_font("font")
	var price_font_size: int = 28
	while price_font_size > 18 and price_font.get_string_size(price_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, price_font_size).x + 6 > price_label.size.x:
		price_font_size -= 1
	price_label.add_theme_font_size_override("font_size", price_font_size)
	earn_button.text = ""
	_refresh_search_glow()
	can_count_label.text = "빈캔 " + _format_amount(cans)
	_refresh_quest_panel()
	shop_button.disabled = inserting_coin or result_overlay.visible or info_overlay.visible
	earn_button.disabled = inserting_coin or result_overlay.visible or info_overlay.visible
	$Navigation/AbilityButton.disabled = inserting_coin or result_overlay.visible
	shop_button.tooltip_text = ""

func _format_amount(amount: int) -> String:
	var digits: String = str(amount)
	var formatted: String = ""
	for i in range(digits.length()):
		if i > 0 and (digits.length() - i) % 3 == 0:
			formatted += ","
		formatted += digits[i]
	return formatted

func _format_gold(amount: int) -> String:
	if amount < 10000:
		return _format_amount(amount)
	var divisor: int = 1000
	var suffix: String = "K"
	if amount >= 1000000000:
		divisor = 1000000000
		suffix = "B"
	elif amount >= 1000000:
		divisor = 1000000
		suffix = "M"
	# 표시만 줄이고 잔액은 그대로 둔다. 반올림으로 잔액을 높여 보이지 않는다.
	var tenths: int = amount / (divisor / 10)
	return "%d.%d%s" % [tenths / 10, tenths % 10, suffix]

func _on_menu_button_pressed() -> void:
	pause_menu.set_open(true)

func _refresh_quest_panel() -> void:
	var minimized: bool = quest_reward_claimed and can_quest_reward_claimed
	var can_quest: bool = quest_reward_claimed
	var target: int = CAN_QUEST_TARGET if can_quest else QUEST_TARGET
	var progress: int = mini(collected_cans(), target) if can_quest else quest_clicks
	var reward: int = CAN_QUEST_REWARD if can_quest else QUEST_REWARD
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
	if get_tree().paused or inserting_coin or result_overlay.visible:
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
	for i in range(DRINK_DATA.size()):
		collected[i] = drink_count(i)
		effects[i] = _drink_cumulative_text(i)
	for i in range(2,DRINK_DATA.size()):
		if drink_unlocked(i):
			active.append(i)
	var summary := "수색 %d회 · 꽝 %.1f%%\n발견 보너스 +%d Gold\n최종 발견 금액 +%.0f%%\n수색 피버 %.0f초\n펀치 피버 %.0f초" % [clicks_required(),miss_chance()*100,coin_bonus(),(reward_multiplier()-1)*100,search_fever_duration(),punch_fever_duration()]
	$InfoOverlay/Card/SkillTree.update_state(cans,active,collected,summary,effects)

func _drink_cumulative_text(index: int) -> String:
	var count := drink_count(index)
	match index:
		0: return "누적 수색 클릭 감소 -%d회 (최소 3회)" % (count / 3)
		1: return "누적 발견 보너스 +%d Gold" % count
		2: return "누적 발견 보너스 +%d Gold" % (count * 2)
		3: return "꽝 확률 감소 최대 %.1f%%p 적용" % minf(count * 0.5,13.0)
		4: return "누적 발견 보너스 +%d Gold" % (count * 3)
		5: return "최종 금액 +%d%% · 펀치 피버 +%d초" % [count,mini(count,10)]
		6: return "발견 보너스 +%d Gold · 획득 시 피버" % (count * 5)
		7: return "누적 최종 발견 금액 +%d%%" % (count * 2)
		8: return "누적 수색 클릭 감소 -%d회 (최소 3회)" % (count / 4)
		12: return "수색 피버 시간 +%d초" % mini(count,10)
		14: return "획득 시 펀치 피버 · 현재 지속 %.0f초" % punch_fever_duration()
	return "누적 획득 %d개 · 빈캔은 공통 재화" % count

func _set_info_layout(skill_mode: bool) -> void:
	var card: Panel = $InfoOverlay/Card
	info_overlay.color = Color(16.0/255,27.0/255,41.0/255,0.53) if skill_mode else Color(0.043,0.067,0.094,0.84)
	$InfoOverlay/Card/Title.visible = not skill_mode
	$InfoOverlay/Card/CloseButton.visible = not skill_mode
	if skill_mode:
		card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		card.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		$InfoOverlay/Card/SkillTree.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		card.position = (info_overlay.size - Vector2(560,560)) * 0.5
		card.size = Vector2(560,560)
		card.remove_theme_stylebox_override("panel")

func _on_unlock_ion_pressed() -> void:
	_on_unlock_drink_requested(2)

func _on_unlock_drink_requested(index: int) -> void:
	if index < 2 or index >= DRINK_DATA.size() or get_tree().paused or not info_overlay.visible or not $InfoOverlay/Card/SkillTree.visible or drink_unlocked(index):
		return
	var data: Dictionary = DRINK_DATA[index]
	if cans < data.cost or (data.parent >= 0 and not drink_unlocked(data.parent)):
		return
	cans -= data.cost
	if index == 2:
		ion_unlocked = true
	else:
		unlocked_drinks.append(index)
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
	var save := ConfigFile.new()
	for key in ["money", "purchase_count", "click_stack", "quest_clicks", "quest_reward_claimed", "can_quest_reward_claimed", "drinks", "cans", "machine_level", "water_count", "green_tea_count", "ion_count", "ion_unlocked", "extra_counts", "unlocked_drinks"]:
		save.set_value("progress", key, get(key))
	last_save_error = save.save(save_path)
	if last_save_error != OK:
		feedback_label.text += " (저장 실패)"

func _load_progress() -> void:
	var save := ConfigFile.new()
	if save.load(save_path) != OK:
		return
	for key in ["money", "click_stack", "quest_clicks", "drinks", "cans", "machine_level"]:
		var value: Variant = save.get_value("progress", key, 0)
		if value is int:
			set(key, clampi(value, 0, 1000000000))
	# 이전 버전에서 마신 음료는 물 수집으로 이어받는다.
	var saved_tea: Variant = save.get_value("progress", "green_tea_count", 0)
	green_tea_count = clampi(saved_tea, 0, 1000000000) if saved_tea is int else 0
	var saved_ion: Variant = save.get_value("progress", "ion_count", 0)
	ion_count = clampi(saved_ion, 0, 1000000000) if saved_ion is int else 0
	ion_unlocked = save.get_value("progress", "ion_unlocked", false) == true
	var saved_water: Variant = save.get_value("progress", "water_count", maxi(0, drinks - green_tea_count - ion_count))
	water_count = clampi(saved_water, 0, 1000000000) if saved_water is int else 0
	extra_counts.clear()
	var saved_counts: Variant = save.get_value("progress","extra_counts",{})
	if saved_counts is Dictionary:
		for i in range(3,DRINK_DATA.size()):
			var count: Variant = saved_counts.get(i,0)
			if count is int:
				extra_counts[i] = clampi(count,0,1000000000)
	unlocked_drinks.clear()
	var saved_unlocks: Variant = save.get_value("progress","unlocked_drinks",[])
	if saved_unlocks is Array:
		for i in saved_unlocks:
			if i is int and i >= 3 and i < DRINK_DATA.size() and not unlocked_drinks.has(i):
				unlocked_drinks.append(i)
	drinks = water_count + green_tea_count + ion_count
	for count in extra_counts.values():
		drinks += int(count)
	# 이전 저장은 누적 음료 획득 수를 구매 횟수로 이어받는다.
	var saved_purchases: Variant = save.get_value("progress", "purchase_count", drinks)
	purchase_count = clampi(saved_purchases, 0, 1000000000) if saved_purchases is int else drinks
	machine_level = mini(machine_level, MAX_MACHINE_LEVEL)
	quest_clicks = mini(quest_clicks, QUEST_TARGET)
	click_stack = mini(click_stack, clicks_required())
	quest_reward_claimed = save.get_value("progress", "quest_reward_claimed", false) == true
	can_quest_reward_claimed = save.get_value("progress", "can_quest_reward_claimed", false) == true
	if not save.has_section_key("progress", "cans"):
		cans = drinks

func _on_pause_save_requested() -> void:
	_save_progress()
	pause_menu.status.text = "저장했습니다." if last_save_error == OK else "저장하지 못했습니다. 다시 시도해주세요."

func _on_pause_quit_requested() -> void:
	_save_progress()
	if last_save_error != OK:
		pause_menu.status.text = "저장하지 못해 종료하지 않았습니다. 다시 시도해주세요."
		return
	get_tree().paused = false
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		_save_progress()

func _exit_tree() -> void:
	var cursor := get_node_or_null("/root/CursorTheme")
	if cursor != null:
		cursor.call("set_punch_mode", false)
