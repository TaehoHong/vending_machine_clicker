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
var search_glow_tween: Tween

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
	_setup_coin_slot()
	_setup_search_area()
	resized.connect(_position_coin_slot)
	_refresh_ui()

func clicks_required() -> int:
	return maxi(3, CLICKS_PER_REWARD - water_count / 3 - drink_count(8) / 4)

func _on_earn_button_pressed() -> void:
	if get_tree().paused or inserting_coin or result_overlay.visible or info_overlay.visible:
		return
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
	var popup := Label.new()
	popup.name = "CoinRewardPopup"
	popup.text = "+%d" % amount
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.add_theme_font_override("font", preload("res://ui/bold_font.tres"))
	popup.add_theme_font_size_override("font_size", 28)
	popup.add_theme_color_override("font_color", Color("f2bd62"))
	popup.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.06, 0.95))
	popup.add_theme_constant_override("outline_size", 6)
	_animate_search_popup(popup, "coin_reward_popups")

func _show_empty_search() -> void:
	_clear_search_popups("coin_reward_popups")
	var popup := TextureRect.new()
	popup.name = "EmptySearchPopup"
	popup.texture = preload("res://ui/crying_icon.svg")
	popup.custom_minimum_size = Vector2(42, 42)
	popup.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	popup.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_animate_search_popup(popup, "empty_search_popups")

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
	if not earn_button.get_rect().has_point(origin):
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
	# 모든 버튼 상태를 투명하게 두어 배경 위에 클릭 영역만 남긴다.
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		earn_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	search_glow.modulate.a = clampf(float(click_stack) / clicks_required(), 0.0, 1.0)

func _refresh_search_glow() -> void:
	if search_glow_tween and search_glow_tween.is_valid():
		search_glow_tween.kill()
	var brightness: float = clampf(float(click_stack) / clicks_required(), 0.0, 1.0)
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
	var coin_style := StyleBoxFlat.new()
	coin_style.bg_color = Color("edbd53")
	coin_style.border_color = Color("fff0b3")
	coin_style.set_border_width_all(3)
	coin_style.set_corner_radius_all(24)
	coin_token.add_theme_stylebox_override("panel", coin_style)
	_position_coin_slot()

func _position_coin_slot() -> void:
	# KEEP_ASPECT_COVER 배경의 확대 및 중앙 크롭과 같은 좌표 변환.
	var image_size: Vector2 = $TextureRect.texture.get_size()
	var factor: float = maxf(size.x / image_size.x, size.y / image_size.y)
	var origin: Vector2 = (size - image_size * factor) * 0.5
	shop_button.position = origin + Vector2(936, 420) * factor
	shop_button.size = Vector2(50, 108) * factor
	earn_button.position = origin + Vector2(665, 650) * factor
	earn_button.size = Vector2(335, 160) * factor
	search_glow.position = origin + Vector2(610, 650) * factor
	search_glow.size = Vector2(440, 180) * factor
	$SlotHint.position = shop_button.position + Vector2(shop_button.size.x + 24, 13)
	$SlotHint.position.x = minf($SlotHint.position.x, size.x - 218)

func _on_shop_button_pressed() -> void:
	if get_tree().paused or inserting_coin or result_overlay.visible or info_overlay.visible:
		return
	if money < DRAW_PRICE:
		feedback_label.text = "음료 뽑기에는 ¥100이 필요합니다. (¥%d 부족)" % (DRAW_PRICE - money)
		return
	inserting_coin = true
	money -= DRAW_PRICE
	last_drink = _roll_drink()
	_apply_drink(last_drink)
	_update_result()
	# 차감과 획득을 함께 즉시 저장해 애니메이션 중 종료해도 음료를 잃지 않는다.
	_finish_action("¥100 투입! 음료가 나오고 있습니다…")
	shop_button.disabled = true
	var target: Vector2 = shop_button.position + shop_button.size * Vector2(0.38, 0.72)
	coin_token.position = target + Vector2(35, 70)
	coin_token.scale = Vector2.ONE
	coin_token.modulate = Color.WHITE
	coin_token.show()
	coin_tween = create_tween()
	coin_tween.set_parallel(true)
	coin_tween.tween_property(coin_token, "position", target, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	coin_tween.tween_property(coin_token, "scale", Vector2(0.12, 0.6), 0.45)
	coin_tween.tween_property(coin_token, "modulate:a", 0.0, 0.15).set_delay(0.35)
	await coin_tween.finished
	coin_token.hide()
	inserting_coin = false
	result_overlay.show()
	_refresh_ui()
	close_button.grab_focus()

func _roll_drink() -> int:
	var pool: Array[int] = [0,1]
	for index in range(2,DRINK_DATA.size()):
		if drink_unlocked(index):
			pool.append(index)
	return pool[randi_range(0,pool.size()-1)]

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
	return index < 2 or (ion_unlocked if index == 2 else unlocked_drinks.has(index))

func miss_chance() -> float:
	return maxf(0.02,0.15-drink_count(3)*0.005)

func reward_multiplier() -> float:
	return 1.0+drink_count(5)*0.01+drink_count(7)*0.02

func calculate_reward(base_amount: int) -> int:
	return maxi(1,floori((base_amount+coin_bonus())*reward_multiplier()))

func _update_result() -> void:
	var data: Dictionary = DRINK_DATA[last_drink]
	result_title.text = "%s 획득!" % data.name
	result_art.texture = load(data.asset)
	$ResultOverlay/Card/Margin/Contents/Halo.modulate = Color(data.color)
	var effects: Array[String] = ["수색 숙련도 +1", "동전 발견 금액 +1 Gold", "동전 발견 금액 +2 Gold", "꽝 확률 -0.5%p", "동전 발견 금액 +3 Gold", "최종 발견 금액 +1%", "동전 발견 금액 +5 Gold", "최종 발견 금액 +2%", "수색 숙련도 +1"]
	result_effect.text = "[center][font_size=21][color=%s]%s[/color][/font_size]\n[color=#A6B3BF]%s\n빈캔 +1 · 획득 즉시 능력치에 적용[/color][/center]" % [data.color,effects[last_drink],data.effect]

func _on_result_close_pressed() -> void:
	result_overlay.hide()
	_refresh_ui()
	shop_button.grab_focus()

func _refresh_ui() -> void:
	money_label.text = _format_amount(money)
	earn_button.text = ""
	_refresh_search_glow()
	can_count_label.text = _format_amount(cans)
	_refresh_quest_panel()
	shop_button.disabled = inserting_coin or result_overlay.visible or info_overlay.visible
	earn_button.disabled = inserting_coin or result_overlay.visible or info_overlay.visible
	$Navigation/AbilityButton.disabled = inserting_coin or result_overlay.visible
	$Navigation/SkillButton.disabled = inserting_coin or result_overlay.visible
	shop_button.tooltip_text = ""

func _format_amount(amount: int) -> String:
	var digits: String = str(amount)
	var formatted: String = ""
	for i in range(digits.length()):
		if i > 0 and (digits.length() - i) % 3 == 0:
			formatted += ","
		formatted += digits[i]
	return formatted

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
	$QuestPanel/QuestText.visible = not minimized
	$QuestPanel/QuestBar.visible = not minimized
	$QuestPanel/RewardHint.visible = not minimized and progress < target
	quest_progress.visible = not minimized
	quest_complete_button.visible = not minimized and progress >= target
	quest_title.text = "퀘스트 모두 완료 ✓" if minimized else ("빈캔 수집" if can_quest else "첫 수집 목표")
	quest_panel.offset_left = -246.0 if minimized else -290.0
	quest_panel.offset_bottom = 108.0 if minimized else 218.0
	quest_title.position.y = 8.0 if minimized else 14.0

func _on_ability_button_pressed() -> void:
	if get_tree().paused or inserting_coin or result_overlay.visible:
		return
	$InfoOverlay/Card/Title.text = "능력 · 캔 수집"
	$InfoOverlay/Card/Catalog.show()
	$InfoOverlay/Card/SkillTree.hide()
	$InfoOverlay/Card/Summary.show()
	$InfoOverlay/Card/Summary.position.y = 360
	$InfoOverlay/Card/Summary.size.y = 120
	for i in range(DRINK_DATA.size()):
		var row: Control = $InfoOverlay/Card/Catalog/Rows.get_node(DRINK_DATA[i].key)
		row.visible = drink_unlocked(i)
		row.get_node("Count").text = "획득 %s개" % _format_amount(drink_count(i))
	$InfoOverlay/Card/Summary.text = "[font_size=14][color=#F2BD62]현재 적용된 능력[/color]\n수색 %d회 · 꽝 확률 %.1f%%\n기본 발견 보너스 +%d Gold\n최종 발견 금액 +%.0f%%\n보유 빈캔 %d개 / 누적 수집 %d개[/font_size]" % [clicks_required(),miss_chance()*100,coin_bonus(),(reward_multiplier()-1)*100,cans,collected_cans()]
	_open_info()

func _on_skill_button_pressed() -> void:
	if get_tree().paused or inserting_coin or result_overlay.visible:
		return
	$InfoOverlay/Card/Title.text = "스킬 트리"
	$InfoOverlay/Card/Catalog.hide()
	$InfoOverlay/Card/Summary.hide()
	$InfoOverlay/Card/SkillTree.show()
	_refresh_skill_tree()
	_open_info()

func _refresh_skill_tree() -> void:
	var active: Array[int] = []
	for i in range(2,DRINK_DATA.size()):
		if drink_unlocked(i):
			active.append(i)
	$InfoOverlay/Card/SkillTree.update_state(cans,active)

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
	for key in ["money", "click_stack", "quest_clicks", "quest_reward_claimed", "can_quest_reward_claimed", "drinks", "cans", "machine_level", "water_count", "green_tea_count", "ion_count", "ion_unlocked", "extra_counts", "unlocked_drinks"]:
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
