extends SceneTree

const SESSION = preload("res://src/game/game_session.gd")
const RULES = preload("res://src/game/automation/facility_rules.gd")
const STORE = preload("res://src/integrations/saves/progress_store.gd")

class FixedSession:
	extends SESSION
	var rolls: Array[float] = []

	func facility_roll() -> float:
		return rolls.pop_front()


func _initialize() -> void:
	call_deferred("run_checks")
	create_timer(15).timeout.connect(func() -> void: quit(1))


func run_checks() -> void:
	var session := FixedSession.new()
	assert(not session.purchase_facility("auto"))
	assert(not session.unlock_facility("auto"))
	session.cans = 25
	session.money = 1500
	assert(session.unlock_facility("auto"))
	assert(not session.unlock_facility("auto"))
	assert(session.purchase_facility("auto"))
	assert(not session.purchase_facility("auto"))
	assert(session.unlock_facility("trash"))
	assert(session.purchase_facility("trash"))
	assert(session.money == 0 and session.cans == 0)
	session.rolls = [0.1, 0.4]
	var event: Dictionary = session.advance_facilities(10.0)
	assert(event.produced == 10 and event.collected == 1)
	assert(session.money == 0 and session.cans == 1)
	assert(session.collect_facility_gold() == 10)
	assert(session.collect_facility_gold() == 0 and session.money == 10)
	session.rolls = [0.1, 0.9]
	session.advance_facilities(10.0)
	var data: Dictionary = RULES.state(session)
	var id: int = data.drops[0].id
	assert(session.collect_facility_item(id) == 1)
	assert(session.collect_facility_item(id) == 0)
	assert(session.cans == 2 and session.drinks == 0 and session.coin_bonus() == 0)
	session.money = 20000
	for key: String in RULES.UPGRADES:
		for level in range(5):
			assert(RULES.upgrade_price(session, key) == 100 * (1 << level))
			assert(session.upgrade_facility(key))
		assert(not session.upgrade_facility(key))
	assert(session.money == 4500)
	assert(RULES.production(session) == 60 and RULES.cycle(session) == 5.0)
	assert(RULES.item_count(session) == 6 and RULES.collection_capacity(session) == 6)
	assert(is_equal_approx(RULES.collection_chance(session), 1.0))

	var timed := FixedSession.new()
	RULES.state(timed).auto_owned = true
	RULES.state(timed).auto_unlocked = true
	timed.rolls = [0.1, 0.1, 0.1]
	event = timed.advance_facilities(35.0)
	var timed_data := RULES.state(timed)
	assert(event.produced == 30 and event.expired == 2)
	assert(timed_data.drops.size() == 1 and timed_data.drops[0].remaining == 10.0)
	assert(timed.collect_facility_item(1) == 0)
	timed.facilities["other_stage"] = {"auto_owned": false, "remaining": 7.0}
	var path := "res://.godot/facilities_%d.cfg" % Time.get_ticks_usec()
	var store := STORE.new(path)
	assert(store.write(timed) == OK)
	var restored := SESSION.new()
	store.load_into(restored)
	assert(restored.facilities == timed.facilities)
	assert(restored.collect_facility_gold() == 30)
	assert(restored.collect_facility_gold() == 0)
	assert(restored.facilities.other_stage.remaining == 7.0)
	DirAccess.remove_absolute(path)
	var normalized := RULES.normalize({"alley": {
		"production": 50, "chance": -2, "drops": [
			{"id": 1, "amount": 1, "remaining": 3.0},
			{"id": 1, "amount": 1, "remaining": 4.0},
			{"id": 2, "amount": 1, "remaining": -1.0},
		],
	}})
	assert(normalized.alley.production == 5 and normalized.alley.chance == 0)
	assert(normalized.alley.drops.size() == 1)
	assert(RULES.normalize({}).alley == RULES.DEFAULT)

	print("Facility rules, production, expiry, upgrades and save compatibility passed.")
	quit()
