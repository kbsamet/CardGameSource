extends Resource
class_name RelicData

var _name : String
var description : String
var on_add : Callable
var on_remove : Callable

static func from_dict(relic_data : Dictionary):
	var new_relic : RelicData = RelicData.new()
	new_relic._name = relic_data["name"]
	new_relic.description = relic_data["description"]
	new_relic.on_add = relic_data["on_add"]
	new_relic.on_remove = relic_data["on_remove"]
	return new_relic
