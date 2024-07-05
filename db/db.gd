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
	Damage,Block,Dodge,Daze,Bleed,Heal,DamageAll
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
	},
	"Pray" : {
		"name" : "Pray",
		"type" : CardType.Reaction,
		"description": "Heal 2 damage.",
		"cost": 2,
		"targeted" : false,
		"effects": {
			CardEffect.Heal : 2,
		}
	},
	"Dodge" : {
		"name" : "Dodge",
		"type" : CardType.Reaction,
		"description": "Dodge the incoming attack.",
		"cost": 2,
		"targeted" : false,
		"effects": {
			CardEffect.Dodge : 1,
		}
	},
	"Slash" : {
		"name" : "Slash",
		"type" : CardType.Action,
		"description": "Deal 5 damage to all enemies.",
		"cost": 2,
		"targeted" : false,
		"effects": {
			CardEffect.DamageAll : 5,
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

var relics : Dictionary = {
	"red_orb" : {
		"name" : "red_orb",
		"description" : "Red Orb:\nGain 1 action point",
		"on_add" : func(player: Player): player.add_max_ap(1),
		"on_remove": func(player: Player): player.add_max_ap(-1)

	},
	"blue_orb" : {
		"name" : "blue_orb",
		"description" : "Blue Orb:\nGain 1 reaction point",
		"on_add" : func(player: Player): player.add_max_rp(1),
		"on_remove": func(player: Player): player.add_max_rp(-1)
		
	},
	"true_faith" : {
		"name" : "true_faith",
		"description" : "True Faith:\nRevive with half health when you would die. Breaks upon use.",
		"on_add" : func(player: Player): player.add_player_status_effect("revive_half",1),
		"on_remove": func(player: Player): player.add_player_status_effect("revive_half",-1)
		
	},
}

const tooltips : Dictionary = {
	"damage" : "Damage: Deal _ damage.",
	"bleed" :  "Bleed: 1 damage per turn for _ turns.",
	"staminaCost": "Cost: This attack will cost _ stamina.",
	"daze" : "Daze: You will be unable to attack for _ turns.",
	"dazed" : "Dazed: This unit will be unable to attack for _ turns.",
	"block" : "Block: Block _ damage. Block is removed at the end of the round",
	"dodge" : "Dodge: Dodge the next attack."
}

const fight_rooms : Array[Dictionary] = [
	{
		"Zombie" : 1,
		"Bat"  : 1
	},
	{
		"Zombie" : 2,
		"Bat"  : 1
	},
	{
		"Zombie" : 2,
	},
	{
		"Bat" : 2,
	},
]

const rewards : Array[Dictionary] = [
	{
		"reward" : "gold",
		"amount" : "10-15",
		"tooltip" : "Gain gold after the next fight."
	},
	{
		"reward" : "key",
		"amount" : 1,
		"tooltip" : "Gain a key after the next fight."
	},
	#{
		#"reward" : "locked_chest",
		#"amount" : 1,
		#"tooltip" : "There is a locked chest after the next fight."
		#
	#},
	{
		"reward" : "choose_card",
		"amount" : 3,
		"tooltip" : "Choose one of 3 cards after the next fight."
		
	},
	{
		"reward" : "choose_relic",
		"amount" : 3,
		"tooltip" : "Choose one of 3 relics after the next fight."
		
	},
	#{
		#"reward" : "shop",
		#"amount" : 1,
		#"tooltip" : "There is a shop after the next fight."
		#
	#},
]


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

