extends RefCounted

const FACILITIES = preload("res://src/game/automation/facility_rules.gd")

var path: String


func _init(save_path: String = "user://progress.cfg") -> void:
	path = save_path


func has_file() -> bool:
	return FileAccess.file_exists(path)


func exists() -> bool:
	var save := ConfigFile.new()
	return save.load(path) == OK and save.get_value("progress", "money", null) is int


func summary() -> String:
	var save := ConfigFile.new()
	save.load(path)
	return (
		"마지막 저장 · %s Gold / 음료 %d개"
		% [
			preload("res://src/shared/formatting/amount_format.gd").format_gold(
				int(save.get_value("progress", "money", 0))
			),
			int(save.get_value("progress", "drinks", 0)),
		]
	)


func backup() -> String:
	if not FileAccess.file_exists(path):
		return ""
	var folder: String = path.get_base_dir().path_join("backups")
	if DirAccess.make_dir_recursive_absolute(folder) != OK:
		return ""
	var target: String = folder.path_join(
		"progress_%d_%d.cfg" % [int(Time.get_unix_time_from_system()), Time.get_ticks_usec()]
	)
	return target if DirAccess.copy_absolute(path, target) == OK else ""


func write(state: RefCounted) -> Error:
	var save := ConfigFile.new()
	for key in [
		"money",
		"purchase_count",
		"click_stack",
		"quest_clicks",
		"quest_reward_claimed",
		"can_quest_reward_claimed",
		"drinks",
		"cans",
		"machine_level",
		"water_count",
		"green_tea_count",
		"ion_count",
		"ion_unlocked",
		"extra_counts",
		"unlocked_drinks",
	]:
		save.set_value("progress", key, state.get(key))
	var facilities: Dictionary = state.facilities.duplicate(true)
	facilities[FACILITIES.STAGE].erase("remaining")
	save.set_value("progress", "facilities", facilities)
	return save.save(path)


func load_into(state: RefCounted) -> void:
	var save := ConfigFile.new()
	if save.load(path) != OK:
		return
	for key in ["money", "click_stack", "quest_clicks", "drinks", "cans", "machine_level"]:
		var value: Variant = save.get_value("progress", key, 0)
		if value is int:
			state.set(key, clampi(value, 0, 1000000000))
	# 이전 버전에서 마신 음료는 물 수집으로 이어받는다.
	var saved_tea: Variant = save.get_value("progress", "green_tea_count", 0)
	state.green_tea_count = clampi(saved_tea, 0, 1000000000) if saved_tea is int else 0
	var saved_ion: Variant = save.get_value("progress", "ion_count", 0)
	state.ion_count = clampi(saved_ion, 0, 1000000000) if saved_ion is int else 0
	state.ion_unlocked = save.get_value("progress", "ion_unlocked", false) == true
	var saved_water: Variant = save.get_value(
		"progress", "water_count", maxi(0, state.drinks - state.green_tea_count - state.ion_count)
	)
	state.water_count = clampi(saved_water, 0, 1000000000) if saved_water is int else 0
	state.extra_counts.clear()
	var saved_counts: Variant = save.get_value("progress", "extra_counts", {})
	if saved_counts is Dictionary:
		for i in range(3, state.DRINK_DATA.size()):
			var count: Variant = saved_counts.get(i, 0)
			if count is int:
				state.extra_counts[i] = clampi(count, 0, 1000000000)
	state.unlocked_drinks.clear()
	var saved_unlocks: Variant = save.get_value("progress", "unlocked_drinks", [])
	if saved_unlocks is Array:
		for i in saved_unlocks:
			if (
				i is int
				and i >= 3
				and i < state.DRINK_DATA.size()
				and not state.unlocked_drinks.has(i)
			):
				state.unlocked_drinks.append(i)
	state.drinks = state.water_count + state.green_tea_count + state.ion_count
	for count in state.extra_counts.values():
		state.drinks += int(count)
	# 이전 저장은 누적 음료 획득 수를 구매 횟수로 이어받는다.
	var saved_purchases: Variant = save.get_value("progress", "purchase_count", state.drinks)
	state.purchase_count = (
		clampi(saved_purchases, 0, 1000000000) if saved_purchases is int else state.drinks
	)
	state.machine_level = mini(state.machine_level, state.MAX_MACHINE_LEVEL)
	state.quest_clicks = mini(state.quest_clicks, state.QUEST_TARGET)
	state.click_stack = mini(state.click_stack, state.clicks_required())
	state.quest_reward_claimed = save.get_value("progress", "quest_reward_claimed", false) == true
	state.can_quest_reward_claimed = (
		save.get_value("progress", "can_quest_reward_claimed", false) == true
	)
	if not save.has_section_key("progress", "cans"):
		state.cans = state.drinks

	state.facilities = FACILITIES.normalize(
		save.get_value("progress", "facilities", {})
	)
