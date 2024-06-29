extends Node
class_name EnemyData

var _name : String
var health : int
var max_health : int
var stamina : int
var max_stamina : int
var attacks : Array
var status_effects : Dictionary

static func fromDict(enemy_data : Dictionary):
	var new_enemy : EnemyData = EnemyData.new()
	new_enemy._name = enemy_data["name"]
	new_enemy.health = enemy_data["health"]
	new_enemy.max_health = enemy_data["health"]
	new_enemy.stamina = enemy_data["stamina"]
	new_enemy.max_stamina = enemy_data["stamina"]
	new_enemy.attacks = enemy_data["attacks"]
	new_enemy.status_effects = enemy_data["statusEffects"]
	return new_enemy
