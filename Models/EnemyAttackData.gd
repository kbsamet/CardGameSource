extends Resource
class_name EnemyAttackData

@export var attacks : Array[EnemySingleAttackData]

func get_stamina_cost()-> int:
	var filtered_attacks : Array[EnemySingleAttackData] = attacks.filter(func(attack : EnemySingleAttackData) -> bool : return attack.attack_type == db.EnemyAttack.StaminaCost)
	if filtered_attacks.is_empty():
		return 0
	return filtered_attacks[0].amount

func get_value_of_type(type : db.EnemyAttack) -> int:
	var filtered_attacks : Array[EnemySingleAttackData] = attacks.filter(func(attack : EnemySingleAttackData) -> bool: return attack.attack_type == type)
	if filtered_attacks.is_empty():
		return -1
	return filtered_attacks[0].amount

func set_value_of_type(type : db.EnemyAttack,new_amount : int) -> void:
	for i in range(attacks.size()):
		if attacks[i].attack_type == type:
			var new_attack : EnemySingleAttackData = attacks[i].duplicate(true)
			new_attack.amount = new_amount
			attacks.remove_at(i)
			attacks.insert(i,new_attack)
		break
