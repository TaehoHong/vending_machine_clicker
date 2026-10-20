extends "res://src/game/progress_state.gd"

# 기존 플레이 테스트용 밸런스다. 확정 기획 수치로 승격하지 않는다.
const CLICKS_PER_REWARD: int = 10
const QUEST_TARGET: int = 10
const QUEST_REWARD: int = 5000
const CAN_QUEST_TARGET: int = 5
const CAN_QUEST_REWARD: int = 100
const DRAW_PRICE: int = 100
const ION_UNLOCK_COST: int = 5
const CANS_PER_BONUS: int = 5
const MAX_MACHINE_LEVEL: int = 4
const COINS: Array[int] = [1, 5, 10, 50, 100, 500, 1000, 5000]
const DRINK_DATA = preload("res://src/data/drink_catalog.gd").DATA
const ECONOMY = preload("res://src/game/economy/economy_rules.gd")
const DRINKS = preload("res://src/game/progression/drink_rules.gd")
const SEARCH = preload("res://src/game/search/search_rules.gd")


func current_draw_price() -> int:
	return ECONOMY.current_draw_price(self)


func coin_bonus() -> int:
	return ECONOMY.coin_bonus(self)


func reward_multiplier() -> float:
	return ECONOMY.reward_multiplier(self)


func calculate_reward(base_amount: int) -> int:
	return ECONOMY.calculate_reward(self, base_amount)


func purchasable_drinks() -> Array[int]:
	return DRINKS.purchasable_drinks(self)


func collected_cans() -> int:
	return DRINKS.collected_cans(self)


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
	var pool := purchasable_drinks()
	return pool[randi_range(0, pool.size() - 1)]


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
	if inserting_coin or money < price:
		return false
	inserting_coin = true
	money -= price
	purchase_count += 1
	last_drink = _roll_drink()
	_apply_drink(last_drink)
	search_fever_pending = last_drink == 6
	punch_fever_pending = last_drink == 14
	return true


func search() -> int:
	if inserting_coin:
		return -1
	click_stack = mini(click_stack + 1, clicks_required())
	if click_stack < clicks_required():
		return -1
	click_stack = 0
	return _discover_coin(1)


func punch() -> int:
	if inserting_coin or punch_fever_remaining <= 0:
		return -1
	return _discover_coin(3)


func _discover_coin(multiplier: int) -> int:
	if _search_is_empty():
		return 0
	var coin_index: int = 0
	while coin_index < 3 + machine_level and randf() < 0.22:
		coin_index += 1
	var earned: int = calculate_reward(COINS[coin_index]) * multiplier
	money += earned
	quest_clicks = mini(quest_clicks + 1, QUEST_TARGET)
	return earned


func unlock(index: int) -> bool:
	if index < 2 or index >= DRINK_DATA.size() or drink_unlocked(index):
		return false
	var data: Dictionary = DRINK_DATA[index]
	if cans < data.cost or (data.parent >= 0 and not drink_unlocked(data.parent)):
		return false
	cans -= data.cost
	if index == 2:
		ion_unlocked = true
	else:
		unlocked_drinks.append(index)
	return true


func claim_quest() -> bool:
	if not quest_reward_claimed:
		if quest_clicks < QUEST_TARGET:
			return false
		quest_reward_claimed = true
		money += QUEST_REWARD
	elif not can_quest_reward_claimed:
		if collected_cans() < CAN_QUEST_TARGET:
			return false
		can_quest_reward_claimed = true
		money += CAN_QUEST_REWARD
	else:
		return false
	return true


func start_search_fever() -> void:
	search_fever_total = search_fever_duration()
	search_fever_remaining = search_fever_total


func start_punch_fever() -> void:
	punch_fever_total = punch_fever_duration()
	punch_fever_remaining = punch_fever_total


func finish_purchase() -> void:
	inserting_coin = false
	if search_fever_pending:
		search_fever_pending = false
		start_search_fever()
	if punch_fever_pending:
		punch_fever_pending = false
		start_punch_fever()


func finish_pending_search_fever() -> void:
	if search_fever_pending:
		search_fever_pending = false
		start_search_fever()


func advance(delta: float, blocked: bool) -> void:
	if blocked:
		return
	search_fever_remaining = maxf(0, search_fever_remaining - delta)
	punch_fever_remaining = maxf(0, punch_fever_remaining - delta)
