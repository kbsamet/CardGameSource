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

enum CardEffect {
	Damage,Block,Dodge,Daze,Bleed,Heal,DamageAll,ConvertAllAp,ConvertAllRp,Crushing,ShieldSlam,Riposte
}
var status_effects : Dictionary = {
	"dazed" : {
		"name" : "dazed",
		"hidden" : false,
		"tooltip" : "Dazed: This unit will be unable to attack for _ turns.",
	},
	"block" : {
		"name" : "block",
		"hidden" : true,
		"tooltip" : "Block: Block _ damage. Block is removed at the end of the round.",
	},
	"bleed" : {
		"name" : "bleed",
		"hidden" : false,
		"tooltip" : "Bleed: _ damage per turn. Reduces by 1 each turn.",
	},
	"dodge" : {
		"name" : "dodge",
		"hidden" : false,
		"tooltip" : "Dodge: Dodge the next attack.",
	},
	"revive_half": {
		"name" : "revive_half",
		"hidden" : true,
		"tooltip" : "",
	},
	"blind": {
		"name" : "blind",
		"hidden" : false,
		"tooltip" : "Blind: You will be unable to target enemies for _ turns.",
	},
	"burn": {
		"name" : "burn",
		"hidden" : false,
		"tooltip" : "Burn: You will discard a random card for _ turns.",
	},
	"crushing": {
		"name" : "crushing",
		"hidden" : false,
		"tooltip" : "Crushing:\nDeal double damage to dazed enemies for _ turns"
	}
	
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
		"description": "Deal 3 damage. Daze the enemy.",
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
		"description": "Deal 5 damage. Daze the enemy.",
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
		"description": "Gain 1 dodge.",
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
	},
	"Offensive Surge": {
		"name" : "Offensive Surge",
		"type" : CardType.Action,
		"description": "Convert all reaction points into action points.",
		"cost": 0,
		"targeted" : false,
		"effects": {
			CardEffect.ConvertAllRp : 1,
		}
	},
	"Defensive Surge": {
		"name" : "Defensive Surge",
		"type" : CardType.Reaction,
		"description": "Convert all action points into reaction points.",
		"cost": 0,
		"targeted" : false,
		"effects": {
			CardEffect.ConvertAllAp : 1,
		}
	},
	"Sharp Blade": {
		"name" : "Sharp Blade",
		"type" : CardType.Action,
		"description": "Inflict 4 bleed to an enemy.",
		"cost": 2,
		"targeted" : true,
		"effects": {
			CardEffect.Bleed : 4,
		}
	},
	"Overpower": {
		"name": "Overpower",
		"type": CardType.Action,
		"description": "Gain 3 crushing.",
		"cost": 2,
		"targeted" : false,
		"effects": {
			CardEffect.Crushing : 3,
		}
	},
	"Shield Slam": {
		"name": "Shield Slam",
		"type": CardType.Reaction,
		"description": "Deal damage equal to your block amount.",
		"cost": 1,
		"targeted" : true,
		"effects": {
			CardEffect.ShieldSlam : 1,
		}
	},
	"Parry": {
		"name": "Parry",
		"type": CardType.Reaction,
		"description": "Stop the enemy attack.",
		"cost": 1,
		"targeted" : true,
		"effects": {
			CardEffect.Daze : 1,
		}
	},
	"Riposte": {
		"name": "Riposte",
		"type": CardType.Reaction,
		"description": "Deal 8 damage if the enemy is not attacking.",
		"cost": 1,
		"targeted" : true,
		"effects": {
			CardEffect.Riposte : 8,
		}
	},
}

var enemies : Dictionary = {
	"Zombie": {
		"name" : "Zombie",
		"health" : 20,
		"stamina" : 3,
		"attacks": [
			{
				"bleed" : 1,
				"damage" : 5,
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
		"health" : 15,
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
	},
	"Fallen Priest": {
		"name" : "Fallen Priest",
		"health" : 25,
		"stamina" : 5,
		"attacks": [
			{
				"armorUp" : 5,
				"healAll" : 3,
				"unstoppable" : 1,
				"staminaCost" : 3
			},
			{
				"damage" : 2,
				"blind" : 2,
				"staminaCost" : 2
			},
			{
				"damage" : 2,
				"staminaCost" : 1
			}
		],
		"statusEffects": {
			"block" : StatusEffectData.fromDict(status_effects["block"],5)
		}
	},
	"Fire Seeker": {
		"name" : "Fire Seeker",
		"health" : 20,
		"stamina" : 5,
		"attacks": [
			{
				"damage" : 5,
				"burn" : 2,
				"staminaCost" : 3
			},
			{
				"damage" : 5,
				"staminaCost" : 2
			},
			{
				"damage" : 2,
				"staminaCost" : 1
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
		"on_add" : func(p: Player): p.add_max_ap(1),
		"on_remove": func(p: Player): p.add_max_ap(-1)

	},
	"blue_orb" : {
		"name" : "blue_orb",
		"description" : "Blue Orb:\nGain 1 reaction point",
		"on_add" : func(p: Player): p.add_max_rp(1),
		"on_remove": func(p: Player): p.add_max_rp(-1)
		
	},
	"true_faith" : {
		"name" : "true_faith",
		"description" : "True Faith:\nRevive with half health when you would die. Breaks upon use.",
		"on_add" : func(p: Player): p.add_player_status_effect("revive_half",1),
		"on_remove": func(p: Player): p.add_player_status_effect("revive_half",-1)
		
	},
}

const enemy_tooltips : Dictionary = {
	"damage" : "Damage: Deal _ damage.",
	"bleed" :  "Bleed: 1 damage per turn for _ turns.",
	"staminaCost": "Cost: This attack will cost _ stamina.",
	"daze" : "Daze: You will be unable to attack for _ turns.",
	"armorUp": "Armor Up: This enemy will gain _ block.",
	"healAll": "Heal All: This enemy will heal all enemies by _.",
	"blind": "Blind: You will be unable to target enemies for _ turns.",
	"burn": "Burn: You will discard a random card for _ turns.",
	"unstoppable": "Unstoppable: This enemy cannot be stunned."
}

const card_tooltips : Dictionary = {
	CardEffect.Block : "Block:\nBlock _ damage for this turn.",
	CardEffect.Dodge : "Dodge:\nDodge the incoming attack.",
	CardEffect.Daze : "Daze:\nThe enemy will be unable to attack for _ turns.",
	CardEffect.Bleed : "Bleed:\nThe enemy will receive _ damage per turn.",
	CardEffect.Crushing : "Crushing:\nDeal double damage to dazed enemies for _ turns"
}

const fight_rooms : Array[Dictionary] = [
	{
		"Zombie" : 1,
		"Bat"  : 2
	},
	{
		"Zombie" : 1,
		"Fallen Priest": 1,
		"Fire Seeker": 1
	},
	{
		"Fallen Priest" : 1,
		"Fire Seeker": 1
	},
	{
		"Bat" : 2,
		"Fallen Priest": 1
	}
	
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
	{
		"reward" : "locked_chest",
		"amount" : 1,
		"tooltip" : "There is a locked chest after the next fight."
		
	},
	{
		"reward" : "choose_card",
		"amount" : 3,
		"tooltip" : "Choose one of 3 cards after the next fight.",
		"multiplier": 5
		
	},
	#{
		#"reward" : "choose_relic",
		#"amount" : 3,
		#"tooltip" : "Choose one of 3 relics after the next fight."
		#
	#},
	#{
		#"reward" : "shop",
		#"amount" : 1,
		#"tooltip" : "There is a shop after the next fight."
		#
	#},
]

const locked_chest_rewards : Array[Dictionary] = [
	{
		"reward": "gold",
		"amount": "15-20"
	},
	{
		"reward": "choose_card",
		"amount": 3
	},
	{
		"reward": "choose_relic",
		"amount": 3
	},
	
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

