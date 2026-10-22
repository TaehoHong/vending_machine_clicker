extends RefCounted


static func current_draw_price(state: RefCounted) -> int:
	# 원래 가격에 복리를 적용하고 결제 금액만 올림해 반올림 오차의 누적을 피한다.
	var price: float = state.DRAW_PRICE * pow(1.05, state.purchase_count)
	if not is_finite(price) or price >= 9.0e18:
		return 9000000000000000000
	return ceili(price - 0.00000001)


static func coin_bonus(state: RefCounted) -> int:
	return drink_coin_bonus(state, 0) + drink_coin_bonus(state, 1) + drink_coin_bonus(state, 9)


static func drink_coin_bonus(state: RefCounted, index: int) -> int:
	var per_drink: int = {0: 1, 1: 3, 9: 5}.get(index, 0)
	return state.enhancement_count(index) * per_drink


static func reward_multiplier(state: RefCounted) -> float:
	return 2.0 if state.search_fever_remaining > 0 else 1.0


static func double_reward_chance(state: RefCounted) -> float:
	return state.enhancement_count(10) * 0.02


static func calculate_reward(state: RefCounted, base_amount: int) -> int:
	return (base_amount + state.coin_bonus()) * int(reward_multiplier(state))
