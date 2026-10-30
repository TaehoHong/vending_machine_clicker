extends "res://src/game/progress_state.gd"

# 기존 플레이 테스트용 밸런스다. 확정 기획 수치로 승격하지 않는다.
const CLICKS_PER_REWARD: int = 10
const QUEST_TARGET: int = 10
const QUEST_REWARD: int = 5000
const CAN_QUEST_TARGET: int = 5
const CAN_QUEST_REWARD: int = 100
const QUEST_IDS: Array[String] = ["coin", "can"]
const DRAW_PRICE: int = 100
const ION_UNLOCK_COST: int = 5
const MAX_MACHINE_LEVEL: int = 4
const COINS: Array[int] = [1, 5, 10, 50, 100, 500, 1000, 5000]
const DRINK_DATA = preload("res://src/data/drink_catalog.gd").DATA
const ECONOMY = preload("res://src/game/economy/economy_rules.gd")
const DRINKS = preload("res://src/game/progression/drink_rules.gd")
const FACILITIES = preload("res://src/game/automation/facility_rules.gd")
const SEARCH = preload("res://src/game/search/search_rules.gd")


func current_draw_price() -> int:
	return ECONOMY.current_draw_price(self)


func coin_bonus() -> int:
	return ECONOMY.coin_bonus(self)


func drink_coin_bonus(index: int) -> int:
	return ECONOMY.drink_coin_bonus(self, index)


func reward_multiplier() -> float:
	return ECONOMY.reward_multiplier(self)


func double_reward_chance() -> float:
	return ECONOMY.double_reward_chance(self)


func double_click_chance() -> float:
	return SEARCH.double_click_chance(self)


func coin_weights() -> Array[int]:
	return SEARCH.coin_weights(self)


func enhancement_count(index: int) -> int:
	return DRINKS.enhancement_count(self, index)


func enhancement_complete(index: int) -> bool:
	return DRINKS.enhancement_complete(self, index)


func golden_chance() -> float:
	return DRINKS.golden_chance(self)


func parking_unlocked() -> bool:
	# 황금 획득 기록 자체가 저장되므로 별도 해금 원장을 중복 저장하지 않는다.
	return drink_count(7) > 0


func calculate_reward(base_amount: int) -> int:
	return ECONOMY.calculate_reward(self, base_amount)


func purchasable_drinks() -> Array[int]:
	return DRINKS.purchasable_drinks(self)


func collected_cans() -> int:
	var lifetime: int = drinks + int(FACILITIES.state(self).collected_cans)
	return maxi(DRINKS.collected_cans(self), lifetime)


func drink_count(index: int) -> int:
	return DRINKS.drink_count(self, index)


func drink_unlocked(index: int) -> bool:
	return DRINKS.drink_unlocked(self, index)


func miss_chance() -> float:
	return DRINKS.miss_chance(self)


func punch_fever_duration() -> float:
	return SEARCH.punch_fever_duration(self)


func search_fever_duration() -> float:
	return SEARCH.search_fever_duration(self)


func clicks_required() -> int:
	return SEARCH.clicks_required(self)


func _roll_drink() -> int:
	return DRINKS.draw_for_roll(self, randf())


func _roll_double_reward() -> bool:
	return randf() < double_reward_chance()


func _roll_double_click() -> bool:
	return randf() < double_click_chance()


func _search_is_empty() -> bool:
	return randf() < miss_chance()


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


func purchase() -> bool:
	var price: int = current_draw_price()
	if money < price or purchasable_drinks().is_empty():
		return false
	var selected: int = _roll_drink()
	if selected < 0 or selected >= DRINK_DATA.size():
		return false
	money -= price
	purchase_count += 1
	last_drink = selected
	_apply_drink(last_drink)
	pending_purchases[purchase_count] = last_drink
	return true


func search() -> int:
	click_stack = mini(click_stack + (2 if _roll_double_click() else 1), clicks_required())
	if click_stack < clicks_required():
		return -1
	click_stack = 0
	return _discover_coin(1)


func punch() -> int:
	if punch_fever_remaining <= 0:
		return -1
	return _discover_coin(3)


func _discover_coin(multiplier: int) -> int:
	if _search_is_empty():
		return 0
	var base_amount: int = SEARCH.coin_for_roll(self, randf())
	var doubled: int = 2 if _roll_double_reward() else 1
	var earned: int = calculate_reward(base_amount) * doubled * multiplier
	money += earned
	quest_clicks = mini(quest_clicks + 1, QUEST_TARGET)
	return earned


func unlock(index: int) -> bool:
	if index < 2 or index >= DRINK_DATA.size() or drink_unlocked(index):
		return false
	var data: Dictionary = DRINK_DATA[index]
	if cans < data.cost:
		return false
	cans -= data.cost
	if index == 2:
		ion_unlocked = true
	else:
		unlocked_drinks.append(index)
	return true


func quest_status(quest_id: String) -> Dictionary:
	if not QUEST_IDS.has(quest_id):
		return {}
	var is_can := quest_id == "can"
	var target: int = CAN_QUEST_TARGET if is_can else QUEST_TARGET
	var progress: int = mini(collected_cans() if is_can else quest_clicks, target)
	var claimed: bool = can_quest_reward_claimed if is_can else quest_reward_claimed
	return {
		"id": quest_id,
		"title": "빈캔 %d개 모으기" % target if is_can else "동전 %d번 발견하기" % target,
		"kind": "빈캔 수집" if is_can else "동전 수집",
		"progress": progress, "target": target,
		"reward": CAN_QUEST_REWARD if is_can else QUEST_REWARD,
		"claimed": claimed, "ready": not claimed and progress >= target,
	}


func claim_quest(quest_id: String) -> bool:
	var quest := quest_status(quest_id)
	if quest.is_empty() or not quest.ready:
		return false
	if quest_id == "coin":
		quest_reward_claimed = true
	else:
		can_quest_reward_claimed = true
	money += int(quest.reward)
	return true


func start_search_fever() -> void:
	search_fever_total = search_fever_duration()
	search_fever_remaining = search_fever_total


func start_punch_fever() -> void:
	punch_fever_total = punch_fever_duration()
	punch_fever_remaining = punch_fever_total


func finish_purchase(purchase_id: int) -> bool:
	if not pending_purchases.has(purchase_id):
		return false
	var completed: int = pending_purchases[purchase_id]
	pending_purchases.erase(purchase_id)
	if completed == 6:
		start_search_fever()
	if completed == 14:
		start_punch_fever()
	return true


func advance(delta: float, blocked: bool) -> void:
	if blocked:
		return
	search_fever_remaining = maxf(0, search_fever_remaining - delta)
	punch_fever_remaining = maxf(0, punch_fever_remaining - delta)


func facility_roll() -> float:
	return randf()


func purchase_facility(kind: String) -> bool:
	return FACILITIES.purchase(self, kind)


func upgrade_facility(key: String) -> bool:
	return FACILITIES.upgrade(self, key)


func collect_facility_gold() -> int:
	return FACILITIES.collect_gold(self)


func collect_facility_item(id: int) -> int:
	return FACILITIES.collect_item(self, id)


func advance_facilities(delta: float) -> Dictionary:
	return FACILITIES.advance(self, delta)
