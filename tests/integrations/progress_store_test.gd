extends SceneTree

const SESSION = preload("res://src/game/game_session.gd")
const STORE = preload("res://src/integrations/saves/progress_store.gd")

var failures: int = 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _initialize() -> void:
	var path: String = "res://.godot/progress_store_%d.cfg" % Time.get_ticks_usec()
	var store: RefCounted = STORE.new(path)
	var source: RefCounted = SESSION.new()
	source.money = 734
	source.water_count = 6
	source.green_tea_count = 2
	source.ion_count = 1
	source.extra_counts = {3: 2, 14: 1}
	source.drinks = 12
	source.cans = 4
	source.purchase_count = 13
	source.ion_unlocked = true
	source.unlocked_drinks.assign([3, 14])
	source.quest_reward_claimed = true
	source.can_quest_reward_claimed = false
	check(store.write(source) == OK, "Progress writes successfully")
	var restored: RefCounted = SESSION.new()
	store.load_into(restored)
	check(
		restored.money == 734 and restored.cans == 4,
		"Spent balance is distinct from lifetime collection"
	)
	check(
		restored.extra_counts[3] == 2 and restored.extra_counts[14] == 1,
		"Integer-keyed drink counts survive serialization"
	)
	check(
		restored.drinks == 12 and restored.purchase_count == 13,
		"Purchase and collection totals remain independent"
	)
	check(
		restored.ion_unlocked and restored.unlocked_drinks == [3, 14],
		"Special and additional unlocks both survive"
	)
	check(
		restored.quest_reward_claimed and not restored.can_quest_reward_claimed,
		"Quest flags remain independent"
	)
	_check_gold_round_trip(store, source, 1000000001)
	_check_gold_round_trip(store, source, 9007199254740993)

	var legacy := ConfigFile.new()
	legacy.set_value("progress", "money", "invalid")
	legacy.set_value("progress", "drinks", 6)
	legacy.set_value("progress", "green_tea_count", "invalid")
	legacy.set_value("progress", "ion_count", -2)
	legacy.set_value("progress", "extra_counts", {3: -5, 4: "invalid", 14: 7, 999: 9})
	legacy.set_value("progress", "unlocked_drinks", [2, 3, 3, "4", 14, 999])
	check(legacy.save(path) == OK, "Legacy fixture writes successfully")
	var migrated: RefCounted = SESSION.new()
	store.load_into(migrated)
	check(
		migrated.money == 0 and migrated.green_tea_count == 0 and migrated.ion_count == 0,
		"Malformed and negative fields keep existing normalization"
	)
	check(migrated.water_count == 6, "Old total becomes water when the water field is absent")
	check(
		(
			migrated.drink_count(3) == 0
			and migrated.drink_count(4) == 0
			and migrated.drink_count(14) == 7
		),
		"Invalid extra counts are ignored or clamped"
	)
	check(
		not migrated.extra_counts.has(999) and migrated.unlocked_drinks == [3, 14],
		"Out-of-range and duplicate unlocks do not enter progress"
	)
	check(
		migrated.drinks == 13 and migrated.cans == 13 and migrated.purchase_count == 13,
		"Missing cans and purchase count inherit reconstructed lifetime total"
	)
	DirAccess.remove_absolute(path)
	print("Progress store checks: %d failures" % failures)
	quit(1 if failures else 0)


func _check_gold_round_trip(store: RefCounted, source: RefCounted, amount: int) -> void:
	source.money = amount
	source.facilities.alley.gold = amount
	check(store.write(source) == OK, "Large Gold balance saves successfully")
	var restored: RefCounted = SESSION.new()
	store.load_into(restored)
	check(restored.money == amount, "Wallet Gold survives loading without truncation")
	check(restored.facilities.alley.gold == amount, "Unclaimed facility Gold survives loading")
