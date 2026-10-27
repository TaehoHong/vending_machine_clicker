extends Node

signal changed

var values: Dictionary = {
	"master": 70.0, "music": 70.0, "effects": 70.0,
	"fullscreen": false, "reduce_motion": false, "locale": "ko",
}
var path: String = "user://settings.cfg"


func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(path) == OK:
		for key: String in values:
			var saved: Variant = config.get_value("preferences", key, values[key])
			if typeof(saved) == typeof(values[key]):
				values[key] = saved
	for bus_name in ["Music", "Effects"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	_apply()


func set_preference(key: String, value: Variant) -> Error:
	assert(values.has(key))
	values[key] = value
	_apply()
	var config := ConfigFile.new()
	for setting: String in values:
		config.set_value("preferences", setting, values[setting])
	var result := config.save(path)
	changed.emit()
	return result


func _apply() -> void:
	for entry: Array in [["master", "Master"], ["music", "Music"], ["effects", "Effects"]]:
		var volume := clampf(float(values[entry[0]]), 0.0, 100.0)
		values[entry[0]] = volume
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(entry[1]), linear_to_db(volume / 100.0)
		)
		AudioServer.set_bus_mute(AudioServer.get_bus_index(entry[1]), volume == 0.0)
	TranslationServer.set_locale(str(values.locale))
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen
			else DisplayServer.WINDOW_MODE_WINDOWED
		)
