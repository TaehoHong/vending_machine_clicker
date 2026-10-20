extends RefCounted


static func purchasable_drinks(state: RefCounted) -> Array[int]:
	var pool: Array[int] = []
	for index in range(state.DRINK_DATA.size()):
		if state.drink_unlocked(index):
			pool.append(index)
	return pool


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
	return maxf(0.02, 0.15 - state.drink_count(3) * 0.005)
