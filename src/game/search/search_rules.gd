extends RefCounted


static func punch_fever_duration(state: RefCounted) -> float:
	return 5.0 + state.enhancement_count(5)


static func search_fever_duration(state: RefCounted) -> float:
	return 10.0 + state.enhancement_count(12)


static func clicks_required(state: RefCounted) -> int:
	var normal: int = state.CLICKS_PER_REWARD - state.enhancement_count(3) / 3
	return maxi(1, normal - 5) if state.search_fever_remaining > 0 else normal


static func double_click_chance(state: RefCounted) -> float:
	return state.enhancement_count(8) * 0.08


static func coin_weights(state: RefCounted) -> Array[int]:
	# 0.01% 단위 정수로 합계 10000을 유지한다.
	var ion: int = state.enhancement_count(2)
	var apple: int = state.enhancement_count(4)
	var miss_weight: int = roundi(state.miss_chance() * 10000)
	var miss_reduction: int = 1500 - miss_weight
	return [
		7000 + miss_reduction - ion * 100 - apple * 200,
		900 + ion * 60 + apple * 120,
		500 + ion * 30 + apple * 60,
		100 + ion * 10 + apple * 20,
		miss_weight,
	]


static func coin_for_roll(state: RefCounted, roll: float) -> int:
	var weights: Array[int] = coin_weights(state)
	# 꽝은 세션의 별도 판정에서 처리하며 성공한 경우의 상대 확률로 추첨한다.
	var pick: float = roll * (10000 - weights[4])
	var cumulative: int = 0
	for index in range(4):
		cumulative += weights[index]
		if pick < cumulative:
			return state.COINS[index]
	return state.COINS[3]
