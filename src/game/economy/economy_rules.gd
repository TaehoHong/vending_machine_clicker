extends RefCounted


static func current_draw_price(state: RefCounted) -> int:
	# 원래 가격에 복리를 적용하고 결제 금액만 올림해 반올림 오차의 누적을 피한다.
	var price: float = state.DRAW_PRICE * pow(1.05, state.purchase_count)
	if not is_finite(price) or price >= 9.0e18:
		return 9000000000000000000
	return ceili(price - 0.00000001)


static func coin_bonus(state: RefCounted) -> int:
	return (
		state.collected_cans() / state.CANS_PER_BONUS
		+ state.green_tea_count
		+ state.ion_count * 2
		+ state.drink_count(4) * 3
		+ state.drink_count(6) * 5
	)


static func reward_multiplier(state: RefCounted) -> float:
	return 1.0 + state.drink_count(5) * 0.01 + state.drink_count(7) * 0.02


static func calculate_reward(state: RefCounted, base_amount: int) -> int:
	var normal: int = maxi(
		1, floori((base_amount + state.coin_bonus()) * state.reward_multiplier())
	)
	return normal * 2 if state.search_fever_remaining > 0 else normal
