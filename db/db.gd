extends Node

const gameOverScreen = preload("res://Scenes/screens/GameOverScreen.tscn")

signal player_state_changed
signal player_status_effect_changed
signal turn_changed(new_turn)

var player : Player = Player.new()

enum Turn {
	PlayerAction,PlayerReaction, EnemyAction,EnemyReaction
}
var current_turn = Turn.PlayerAction

enum CardType {
	Action,Reaction
} 

enum CardEffect{
	Damage,Block,Dodge,Daze,Bleed
}

var cards : Dictionary = {
	"Strike" :{
		"name" : "Strike",
		"type" : CardType.Action,
		"description": "Deal 5 damage",
		"cost": 1,
		"targeted" : true,
		"effects": {
			 CardEffect.Damage : 5
		}
	},
	"Shield Bash" : {
		"name": "Shield Bash",
		"type" : CardType.Reaction,
		"description": "Deal 3 damage. Stun the enemy.",
		"cost": 2,
		"targeted" : true,
		"effects": {
			CardEffect.Damage : 3,
			CardEffect.Daze : 1
		}
	},
	"Block" :{
		"name" : "Block",
		"type" : CardType.Reaction,
		"description": "Block 3 damage",
		"cost": 1,
		"targeted" : false,
		"effects": {
			CardEffect.Block : 3
		}
	},
	"Daze" : {
		"name" : "Daze",
		"type" : CardType.Action,
		"description": "Deal 5 damage. Stun the enemy.",
		"cost": 2,
		"targeted" : true,
		"effects": {
			CardEffect.Damage : 5,
			CardEffect.Daze : 1,
		}
	}
}

var enemies : Dictionary = {
	"Zombie": {
		"name" : "Zombie",
		"health" : 15,
		"stamina" : 3,
		"attacks": [
			{
				"damage" : 5,
				"bleed" : 1,
				"staminaCost" : 3
			},
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
	},
	"Bat": {
		"name" : "Bat",
		"health" : 10,
		"stamina" : 2,
		"attacks": [
			{
				"damage" : 3,
				"daze" : 1,
				"staminaCost" : 2
			},
			{
				"damage" : 3,
				"bleed" : 3,
				"staminaCost" : 2
			}
		],
		"statusEffects": {
		}
	}
}

const tooltips : Dictionary = {
	"damage" : "Damage: Deal _ damage.",
	"bleed" :  "Bleed: 1 damage per turn for _ turns.",
	"staminaCost": "Cost: This attack will cost _ stamina.",
	"daze" : "Daze: You will be unable to attack for _ turns.",
	"dazed" : "Dazed: This unit will be unable to attack for _ turns.",
	"block" : "Block: Block _ damage. Block is removed at the end of the round"
}


func remove_from_deck(card_index):
	player.deck.remove_at(card_index)
	player_state_changed.emit()

func shuffle_discard_to_deck():
	player.deck = player.discardPile.duplicate(true)
	player.discardPile = []
	player_state_changed.emit()
	
	
func set_turn(newTurn : Turn):
	current_turn = newTurn
	turn_changed.emit(newTurn)

func  reset_player():
	player.reset()
	
func check_game_over():
	if player.health <= 0:
		get_tree().change_scene_to_packed(gameOverScreen)
