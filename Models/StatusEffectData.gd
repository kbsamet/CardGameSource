extends Resource

class_name StatusEffectData

var _name : String
var amount : int = 0
var tooltip : String
var hidden : bool = false

static func fromDict(effect_data : Dictionary,_amount : int) -> StatusEffectData:
	var new_effect : StatusEffectData = StatusEffectData.new()
	new_effect._name = effect_data["name"]
	new_effect.tooltip = effect_data["tooltip"]
	new_effect.hidden = effect_data["hidden"]
	new_effect.amount = _amount
	return new_effect
