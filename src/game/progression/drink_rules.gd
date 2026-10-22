extends RefCounted


static func purchasable_drinks(state: RefCounted) -> Array[int]:
	var pool: Array[int] = []
	for index in range(state.DRINK_DATA.size()):
		if (
			state.drink_unlocked(index)
			and (index in [6, 14] or not enhancement_complete(state, index))
		):
			pool.append(index)
	return pool


static func enhancement_count(state: RefCounted, index: int) -> int:
	return mini(state.drink_count(index), int(state.DRINK_DATA[index].max_enhancements))


static func enhancement_complete(state: RefCounted, index: int) -> bool:
	return enhancement_count(state, index) == int(state.DRINK_DATA[index].max_enhancements)


static func all_normal_enhancements_complete(state: RefCounted) -> bool:
	for index in range(state.DRINK_DATA.size()):
		if index != 7 and not enhancement_complete(state, index):
			return false
	return true


static func golden_chance(state: RefCounted) -> float:
	if not state.drink_unlocked(7) or enhancement_complete(state, 7):
		return 0.0
	if all_normal_enhancements_complete(state):
		return 1.0
	return minf(0.10, 0.001 + enhancement_count(state, 13) * 0.01)


static func draw_for_roll(state: RefCounted, roll: float) -> int:
	var pool: Array[int] = purchasable_drinks(state)
	if pool.is_empty():
		return -1
	var chance: float = golden_chance(state)
	if chance > 0.0 and (chance >= 1.0 or roll < chance):
		return 7
	pool.erase(7)
	if pool.is_empty():
		return 7
	var normal_roll: float = (roll - chance) / (1.0 - chance) if chance < 1.0 else 0.0
	var slot: int = clampi(floori(normal_roll * pool.size()), 0, pool.size() - 1)
	return pool[slot]


static func collected_cans(state: RefCounted) -> int:
	return maxi(state.cans, state.drinks)


static func drink_count(state: RefCounted, index: int) -> int:
	match index:
		0:
			return state.water_count
		1:
			return state.green_tea_count
		2:
			return state.ion_count
	return int(state.extra_counts.get(index, 0))


static func drink_unlocked(state: RefCounted, index: int) -> bool:
	return (
		index >= 0
		and index < state.DRINK_DATA.size()
		and (index < 2 or (state.ion_unlocked if index == 2 else state.unlocked_drinks.has(index)))
	)


static func miss_chance(state: RefCounted) -> float:
	return 0.15 - enhancement_count(state, 11) * 0.02
