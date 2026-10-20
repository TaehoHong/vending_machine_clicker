extends RefCounted


static func punch_fever_duration(state: RefCounted) -> float:
	return 5.0 + mini(state.drink_count(5), 10)


static func search_fever_duration(state: RefCounted) -> float:
	return 10.0 + mini(state.drink_count(12), 10)


static func clicks_required(state: RefCounted) -> int:
	var normal: int = maxi(
		3, state.CLICKS_PER_REWARD - state.water_count / 3 - state.drink_count(8) / 4
	)
	return maxi(1, normal - 5) if state.search_fever_remaining > 0 else normal
