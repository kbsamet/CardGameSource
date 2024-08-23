extends Resource
class_name EnemyData

@export var _name : String
@export var health : int
@export var max_health : int
@export var stamina : int
@export var max_stamina : int
@export var difficulty : int

@export var attacks : Array[EnemyAttackData]
@export var status_effects : Array[StatusEffectData]
@export var occluder : OccluderPolygon2D

func get_status_effect_data(effect : String) -> StatusEffectData:
	var filtered_status_effects : Array[StatusEffectData] = status_effects.filter(func(e : StatusEffectData) -> bool : return e._name == effect)
	if filtered_status_effects.is_empty():
		return null
	else:
		return filtered_status_effects[0]
func get_status_effect(effect : String) -> int:
	var filtered_status_effects : Array[StatusEffectData] = status_effects.filter(func(e : StatusEffectData) -> bool : return e._name == effect)
	if filtered_status_effects.is_empty():
		return -1
	else:
		return -1 if filtered_status_effects[0].amount == 0 else filtered_status_effects[0].amount

func remove_status_effect(effect : String) -> void:
	status_effects = status_effects.filter(func(e : StatusEffectData) -> bool : return e._name != effect)

func add_status_effect(effect: String, amount:int) -> void:
	var filtered_status_effects : Array[StatusEffectData] = status_effects.filter(func(e: StatusEffectData) -> bool : return e._name == effect)
	if filtered_status_effects.is_empty():
		status_effects.push_back(db.get_status_effect(effect,amount))
	else:
		filtered_status_effects[0].amount += amount
		
