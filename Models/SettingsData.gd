extends Resource
class_name SettingsData

var musicVolume : int
var sfxVolume : int

func save_settings() -> void:
	var save_file : FileAccess = FileAccess.open("user://settings.conf", FileAccess.WRITE)
	var save_data : Dictionary = {
		"sfxVolume" : sfxVolume,
		"musicVolume" : musicVolume
	}
	var json_string : String = JSON.stringify(save_data)
	save_file.store_line(json_string)

static func load_settings() -> SettingsData:
	if not FileAccess.file_exists("user://settings.conf"):
		var empty_settings : SettingsData = SettingsData.new()
		empty_settings.musicVolume = 70
		empty_settings.sfxVolume = 70
		return empty_settings
	
	var save_file : FileAccess = FileAccess.open("user://settings.conf", FileAccess.READ)

	var json_string : String = save_file.get_line()
	var json : JSON = JSON.new()

	# Check if there is any error while parsing the JSON string, skip in case of failure.
	var parse_result : Error= json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		

	# Get the data from the JSON object.
	var node_data : Variant = json.data
	var loaded_settings : SettingsData = SettingsData.new()
	loaded_settings.musicVolume = node_data["musicVolume"]
	loaded_settings.sfxVolume = node_data["sfxVolume"]
		
	return loaded_settings
