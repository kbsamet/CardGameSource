extends Node

signal player_state_changed

var Player = {
	"maxHealth" : 20,
	"health" : 20,
	"maxAp" : 3,
	"ap" : 3,
	"maxRp" : 3,
	"rp" : 3,
}


enum CardType {
	Action,Reaction
} 

enum CardEffect{
	Damage,Block
}

const cards = {
	"Strike":{
		"type" : CardType.Action,
		"description": "Deal 5 damage",
		"cost": 1,
		"effects": {
			 CardEffect.Damage : 5
		}
	},
	"Block":{
		"type" : CardType.Reaction,
		"description": "Block 5 damage",
		"cost": 1,
		"effects": {
			CardEffect.Block : 3
		}
	}
}

const enemies = {
	"Zombie" : {
		"health" : 15,
		"stamina" : 5,
		"attacks": [
			{
				"damage" : 3
			}
		]
	}
}

class Card:
	var _name : String
	var type : CardType
	var description: String
	var cost : int
	var effects
	
	func _init(key:String):
		assert(db.cards.has(key),"The card " + key + " does not exist.")
		_name = key
		var card_data = db.cards[key]
		type = card_data["type"]
		description = card_data["description"]
		cost = card_data["cost"]
		effects = card_data["effects"]
		

class Enemy:
	var _name : String
	var health : int
	var stamina : int
	var max_health : int
	var max_stamina : int
	var attacks : Array
	func _init(key:String):
		assert(db.enemies.has(key),"The Enemy " + key + " does not exist.")
		_name = key
		var enemy_data = db.enemies[key]
		health = enemy_data["health"]
		stamina = enemy_data["stamina"]
		max_health = health
		max_stamina = stamina
		attacks = enemy_data["attacks"]

func change_player_stat(stat,new_stat):
	Player[stat] = new_stat
	player_state_changed.emit()
