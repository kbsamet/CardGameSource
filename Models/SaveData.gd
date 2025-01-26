extends Resource
class_name SaveData

var souls : int
var ability_progresses : Dictionary
var soulbound_cards : Array
var soulbound_relics : Array
var seen_hunter : bool
var hunter_done : bool

func save_game() -> void:
	var save_file : FileAccess = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_data : Dictionary = {
		"souls" : souls,
		"ability_progresses" : ability_progresses,
		"soulbound_cards" : soulbound_cards,
		"soulbound_relics" : soulbound_relics,
		"seen_hunter" : seen_hunter,
		"hunter_done" : hunter_done
 	}
	
	var json_string : String = JSON.stringify(save_data)
	save_file.store_line(json_string)

static func load_save() -> SaveData:
	if not FileAccess.file_exists("user://savegame.save"):
		var empty_save : SaveData = SaveData.new()
		empty_save.souls = 0
		for ability : AbilityData in db.abilities:
			empty_save.ability_progresses[ability._name] = 0
		empty_save.soulbound_cards = []
		empty_save.soulbound_relics = []
		empty_save.seen_hunter = false
		empty_save.hunter_done = false
		return empty_save
	
	var save_file : FileAccess = FileAccess.open("user://savegame.save", FileAccess.READ)

	var json_string : String = save_file.get_line()
	var json : JSON = JSON.new()

	# Check if there is any error while parsing the JSON string, skip in case of failure.
	var parse_result : Error= json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		

	# Get the data from the JSON object.
	var node_data : Variant = json.data
	var loaded_save : SaveData = SaveData.new()
	loaded_save.souls = node_data["souls"]
	loaded_save.ability_progresses = node_data["ability_progresses"]
	if "soulbound_cards" in node_data:
		loaded_save.soulbound_cards = node_data["soulbound_cards"]
	if "soulbound_relics" in node_data:
		loaded_save.soulbound_relics = node_data["soulbound_relics"]
	if "seen_hunter" in node_data:
		loaded_save.seen_hunter = node_data["seen_hunter"]
	if "hunter_done" in node_data:
		loaded_save.hunter_done = node_data["hunter_done"]
	return loaded_save
