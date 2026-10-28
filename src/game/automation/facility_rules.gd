extends RefCounted

# 첫 골목 스테이지의 확정 수치. 다른 스테이지의 상품·시설 인덱스로 재사용하지 않는다.
const STAGE: String = "alley"
const CATALOG: Dictionary = {
	"auto": {"cost": 10},
	"trash": {"cost": 15},
}
const UPGRADES: Dictionary = {
	"production": "auto", "cycle": "auto", "items": "auto",
	"chance": "trash", "capacity": "trash",
}
const DEFAULT: Dictionary = {
	"auto_unlocked": false, "trash_unlocked": false,
	"auto_owned": false, "trash_owned": false,
	"production": 0, "cycle": 0, "items": 0, "chance": 0, "capacity": 0,
	"remaining": 10.0, "gold": 0, "drops": [], "next_drop_id": 0,
	"collected_cans": 0,
}
const MAX_LEVEL: int = 5
const DROP_LIFETIME: float = 15.0


static func state(session: RefCounted) -> Dictionary:
	return session.facilities[STAGE]


static func production(session: RefCounted) -> int:
	return 10 + 10 * int(state(session).production)


static func cycle(session: RefCounted) -> float:
	return 10.0 - float(state(session).cycle)


static func item_count(session: RefCounted) -> int:
	return 1 + int(state(session).items)


static func collection_chance(session: RefCounted) -> float:
	return 0.5 + 0.1 * float(state(session).chance)


static func collection_capacity(session: RefCounted) -> int:
	return 1 + int(state(session).capacity)


static func upgrade_price(session: RefCounted, key: String) -> int:
	return 100 * (1 << int(state(session)[key]))


static func purchase(session: RefCounted, kind: String) -> bool:
	if not CATALOG.has(kind):
		return false
	var data := state(session)
	if data[kind + "_owned"] or session.cans < CATALOG[kind].cost:
		return false
	session.cans -= int(CATALOG[kind].cost)
	data[kind + "_unlocked"] = true
	data[kind + "_owned"] = true
	return true


static func upgrade(session: RefCounted, key: String) -> bool:
	if not UPGRADES.has(key):
		return false
	var data := state(session)
	if not data[UPGRADES[key] + "_owned"] or int(data[key]) >= MAX_LEVEL:
		return false
	var cost := upgrade_price(session, key)
	if session.money < cost:
		return false
	session.money -= cost
	data[key] = int(data[key]) + 1
	data.remaining = minf(float(data.remaining), cycle(session))
	return true


static func collect_gold(session: RefCounted) -> int:
	var data := state(session)
	var amount: int = data.gold
	data.gold = 0
	session.money += amount
	return amount


static func collect_item(session: RefCounted, id: int) -> int:
	var data := state(session)
	for drop: Dictionary in data.drops:
		if int(drop.id) != id:
			continue
		var amount: int = drop.amount
		data.drops.erase(drop)
		session.cans += amount
		data.collected_cans = int(data.collected_cans) + amount
		return amount
	return 0


static func advance(session: RefCounted, delta: float) -> Dictionary:
	var result := {"produced": 0, "collected": 0, "expired": 0}
	var data := state(session)
	var time_left := maxf(delta, 0.0)
	while time_left > 0:
		var step := minf(time_left, float(data.remaining)) if data.auto_owned else time_left
		for drop: Dictionary in data.drops.duplicate():
			drop.remaining = float(drop.remaining) - step
			if float(drop.remaining) <= 0:
				data.drops.erase(drop)
				result.expired += 1
		time_left -= step
		if not data.auto_owned:
			break
		data.remaining = float(data.remaining) - step
		if float(data.remaining) > 0:
			continue
		data.remaining = cycle(session)
		data.gold = int(data.gold) + production(session)
		result.produced += production(session)
		if session.facility_roll() >= 0.2:
			continue
		var amount := item_count(session)
		if data.trash_owned and session.facility_roll() < collection_chance(session):
			var collected := mini(amount, collection_capacity(session))
			amount -= collected
			session.cans += collected
			data.collected_cans = int(data.collected_cans) + collected
			result.collected += collected
		if amount > 0:
			data.next_drop_id = int(data.next_drop_id) + 1
			data.drops.append({
				"id": int(data.next_drop_id), "amount": amount, "remaining": DROP_LIFETIME,
			})
	return result


static func normalize(saved: Variant) -> Dictionary:
	var result := DEFAULT.duplicate(true)
	if not saved is Dictionary:
		return {STAGE: result}
	var stages: Dictionary = saved.duplicate(true)
	stages[STAGE] = result
	var data: Variant = saved.get(STAGE, {})
	if not data is Dictionary:
		return stages
	for key: String in DEFAULT:
		if key in ["drops", "remaining"]:
			continue
		var value: Variant = data.get(key, DEFAULT[key])
		if DEFAULT[key] is bool and value is bool:
			result[key] = value
		elif DEFAULT[key] is int and value is int:
			result[key] = clampi(value, 0, MAX_LEVEL if UPGRADES.has(key) else 1000000000)
	# 생산 진행 시간은 복원하지 않고 현재 강화 단계의 전체 주기로 다시 시작한다.
	result.remaining = 10.0 - float(result.cycle)
	for kind: String in CATALOG:
		# 이전 해금 저장은 빈캔 비용을 이미 지불했으므로 바로 보유 상태로 잇는다.
		if result[kind + "_unlocked"]:
			result[kind + "_owned"] = true
		if result[kind + "_owned"]:
			result[kind + "_unlocked"] = true
	var drops: Variant = data.get("drops", [])
	var ids: Array[int] = []
	if drops is Array:
		for drop: Variant in drops:
			if not drop is Dictionary:
				continue
			if not drop.get("id") is int or not drop.get("amount") is int:
				continue
			var remaining: Variant = drop.get("remaining", 0)
			if not (remaining is float or remaining is int) or not is_finite(float(remaining)):
				continue
			if drop.id <= 0 or ids.has(drop.id) or drop.amount <= 0 or float(remaining) <= 0:
				continue
			ids.append(drop.id)
			result.next_drop_id = maxi(result.next_drop_id, drop.id)
			result.drops.append({
				"id": drop.id, "amount": clampi(drop.amount, 1, 6),
				"remaining": minf(float(remaining), DROP_LIFETIME),
			})
	return stages
