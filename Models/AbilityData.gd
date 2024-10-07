extends Resource
class_name AbilityData

@export var _name : String
@export var cost : int
@export var tooltip : String
@export var level : int = 1
@export var values : Array[int]
@export var improve_amounts : Array[int]
@export var soul_requirement : int

func get_tooltip() -> String:
	var new_tooltip : String = String(tooltip)
	for i in range(values.size()):
		new_tooltip = new_tooltip.replace("/value" + str(i+1),str(values[i]))
	new_tooltip = new_tooltip.replace("/cost",str(cost))
	return new_tooltip

func improve_ability() -> void:
	for i in range(values.size()):
		values[i] += improve_amounts[i]
	db.player.gold -= 50
	level += 1
	db.player_state_changed.emit()
