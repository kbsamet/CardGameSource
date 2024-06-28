extends Node

signal player_state_changed
signal player_status_effect_changed
signal turn_changed(new_turn)

var Player = {
	"maxHealth" : 20,
	"health" : 20,
	"maxAp" : 2,
	"ap" : 2,
	"maxRp" : 2,
	"rp" : 2,
	"handSize" : 5,
	"deckSize": 10,
	"statusEffects": {
	},
	"deck": [],
	"discardPile":[]
}

enum Turn {
	PlayerAction,PlayerReaction, EnemyAction,EnemyReaction
}
var current_turn = Turn.PlayerAction

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
		"targeted" : true,
		"effects": {
			 CardEffect.Damage : 5
		}
	},
	"Block":{
		"type" : CardType.Reaction,
		"description": "Block 5 damage",
		"cost": 1,
		"targeted" : false,
		"effects": {
			CardEffect.Block : 3
		}
	}
}

const enemies = {
	"Zombie" : {
		"health" : 15,
		"stamina" : 3,
		"attacks": [
			{
				"damage" : 3,
				"staminaCost" : 2
			},
			{
				"damage" : 1,
				"staminaCost" : 1
			}
		],
		"statusEffects": {
		}
	}
}

class Card:
	var _name : String
	var type : CardType
	var description: String
	var cost : int
	var targeted : bool
	var effects
	
	func _init(key:String):
		assert(db.cards.has(key),"The card " + key + " does not exist.")
		_name = key
		var card_data = db.cards[key]
		type = card_data["type"]
		description = card_data["description"]
		cost = card_data["cost"]
		effects = card_data["effects"]
		targeted = card_data["targeted"]

class Enemy:
	var _name : String
	var health : int
	var stamina : int
	var max_health : int
	var max_stamina : int
	var attacks : Array
	var status_effects : Dictionary
	func _init(key:String):
		assert(db.enemies.has(key),"The Enemy " + key + " does not exist.")
		_name = key
		var enemy_data = db.enemies[key]
		health = enemy_data["health"]
		stamina = enemy_data["stamina"]
		max_health = health
		max_stamina = stamina
		attacks = enemy_data["attacks"]
		status_effects = enemy_data["statusEffects"].duplicate()

func damage_player(amount):
	if "block" in Player.statusEffects:
		if Player.statusEffects.block > amount:
			change_player_status_effect("block", Player.statusEffects.block - amount)
			return
		change_player_stat("health", Player.health - (amount - Player.statusEffects.block))
		if Player.statusEffects.block != 0:
			change_player_status_effect("block", 0)
	else:
		change_player_stat("health", Player.health - amount)
		
func change_player_stat(stat,new_stat):
	Player[stat] = new_stat
	player_state_changed.emit()
	
func remove_from_deck(card_index):
	Player.deck.remove_at(card_index)
	player_state_changed.emit()

func shuffle_discard_to_deck():
	Player.deck = Player.discardPile.duplicate(true)
	Player.discardPile = []
	player_state_changed.emit()
	
func change_player_status_effect(effect,new_stat):
	Player.statusEffects[effect] = new_stat
	player_status_effect_changed.emit()
	
func set_turn(newTurn : Turn):
	current_turn = newTurn
	turn_changed.emit(newTurn)
