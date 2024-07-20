extends Node

@onready var background_music = preload("res://Sounds/Music/backgroundMusic.tscn")

@onready var all_cards : ResourceGroup = preload("res://Resources/all_cards.tres")
@onready var all_status_effects : ResourceGroup = preload("res://Resources/all_status_effects.tres")
@onready var all_enemies : ResourceGroup = preload("res://Resources/all_enemies.tres")

var cards : Array[CardData] 
var status_effects : Array[StatusEffectData]
var enemies : Array[EnemyData]
func _ready():
	DialogueManager.DialogueSettings.set_setting("balloon_path","res://Dialogues/balloon.tscn")
	all_cards.load_all_into(cards)
	all_status_effects.load_all_into(status_effects)
	all_enemies.load_all_into(enemies)
	var music = background_music.instantiate() as AudioStreamPlayer
	add_child(music)
	music.play()
func _process(delta):
	pass
	#print("FPS: " + str(Engine.get_frames_per_second()))
const gameOverScreen = preload("res://Scenes/screens/GameOverScreen.tscn")

signal level_changed
signal player_state_changed
signal player_status_effect_changed
signal turn_changed(new_turn)

var player : Player = Player.new()
var current_room : int = 1
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

enum EnemyAttack {
	Bleed,Damage,StaminaCost,Daze,Blind,ArmorUp,HealAll,Unstoppable,Burn,Empower
}

enum ItemEffect {
	Heal,Drunk,Tipsy,Cost
}

var relics : Dictionary = {
	"red_orb" : {
		"name" : "red_orb",
		"description" : "Red Orb:\nGain 1 action point",
		"on_add" : func(p: Player): p.add_max_ap(1),
		"on_remove": func(p: Player): p.add_max_ap(-1),
		"cost": 40

	},
	"blue_orb" : {
		"name" : "blue_orb",
		"description" : "Blue Orb:\nGain 1 reaction point",
		"on_add" : func(p: Player): p.add_max_rp(1),
		"on_remove": func(p: Player): p.add_max_rp(-1),
		"cost": 30
		
	},
	"true_faith" : {
		"name" : "true_faith",
		"description" : "True Faith:\nRevive with half health when you would die. Breaks upon use.",
		"on_add" : func(p: Player): p.add_player_status_effect("revive_half",1),
		"on_remove": func(p: Player): p.add_player_status_effect("revive_half",-1),
		"cost": 40
		
	},
}

const enemy_tooltips : Dictionary = {
	db.EnemyAttack.Damage : "Damage: Deal _ damage.",
	db.EnemyAttack.Bleed :  "Bleed: 1 damage per turn for _ turns.",
	db.EnemyAttack.StaminaCost: "Cost: This attack will cost _ stamina.",
	db.EnemyAttack.Daze : "Daze: You will be unable to attack for _ turns.",
	db.EnemyAttack.ArmorUp: "Armor Up: This enemy will gain _ block.",
	db.EnemyAttack.HealAll: "Heal All: This enemy will heal all enemies by _.",
	db.EnemyAttack.Blind: "Blind: You will be unable to target enemies for _ turns.",
	db.EnemyAttack.Burn: "Burn: You will discard a random card for _ turns.",
	db.EnemyAttack.Unstoppable: "Unstoppable: This enemy cannot be stunned.",
	db.EnemyAttack.Empower: "Empower: All enemies will do _ more damage."
}

const card_tooltips : Dictionary = {
	CardEffect.Block : "Block:\nBlock _ damage for this turn.",
	CardEffect.Dodge : "Dodge:\nDodge the incoming attack.",
	CardEffect.Daze : "Daze:\nThe enemy will be unable to attack for _ turns.",
	CardEffect.Bleed : "Bleed:\nThe enemy will receive _ damage per turn.",
	CardEffect.Crushing : "Crushing:\nDeal double damage to dazed enemies for _ turns"
}

const dialogue_tooltips : Dictionary = {
	"beer" : "Beer:\nRestore 5 health. Lose 1 max ap for 1 fight.",
	"wine" : "Wine:\nRestore 10 health. Lose 1 max ap for 2 fights.",
	"whiskey" : "Whiskey:\nRestore 10 health.Gain +1 max ap and -1 max rp for 3 fights."
}

const items : Dictionary = {
	"beer" : {
		ItemEffect.Heal : 5,
		ItemEffect.Tipsy : 1,
		ItemEffect.Cost : 10
	},
	"wine" : {
		ItemEffect.Heal : 10,
		ItemEffect.Tipsy : 2,
		ItemEffect.Cost : 20
	},
	"whiskey" : {
		ItemEffect.Heal : 10,
		ItemEffect.Drunk : 3,
		ItemEffect.Cost : 30
	}
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
		"Zombie" : 1,
		"Minotaur": 1
	},
	{
		"Bat" : 2,
		"Minotaur": 1
	},
	{
		"Minotaur" : 1,
		"Fallen Priest": 1
	},
	{
		"Fire Seeker" : 1,
		"Minotaur" : 1,
		"Fallen Priest": 1
	}
	
]

const rewards : Array[Dictionary] = [
	{
		"reward" : "gold",
		"amount" : "10-15",
		"tooltip" : "Gain gold after the next fight.",
		"multiplier": 3
	},
	{
		"reward" : "key",
		"amount" : 1,
		"tooltip" : "Gain a key after the next fight.",
		"multiplier": 3
	},
	{
		"reward" : "locked_chest",
		"amount" : 1,
		"tooltip" : "There is a locked chest after the next fight.",
		"multiplier": 2
		
	},
	{
		"reward" : "choose_card",
		"amount" : 3,
		"tooltip" : "Choose one of 3 cards after the next fight.",
		"multiplier": 3
		
	},
	#{
		#"reward" : "choose_relic",
		#"amount" : 3,
		#"tooltip" : "Choose one of 3 relics after the next fight."
		#
	#},
	{
		"reward" : "tavern",
		"amount" : 1,
		"tooltip" : "There is a tavern after the next fight.",
		"multiplier": 1
		
	},
]

const locked_chest_rewards : Array[Dictionary] = [
	{
		"reward": "gold",
		"amount": "25-30",
		"multiplier" : 3
	},
	{
		"reward": "choose_card",
		"amount": 3,
		"multiplier" : 2
	},
	{
		"reward": "choose_relic",
		"amount": 3,
		"multiplier" : 1
	},
	
]

const npcs : Dictionary = {
	"Bartender" : {
		"name" : "Bartender",
		"position" : Vector2(74,309),
		"dialogue_offset" : Vector2(220,0)

	},
	"Wizard" : {
		"name" : "Wizard",
		"position" : Vector2(1149,192),
		"dialogue_offset" : Vector2(-100,-130)
	},
	"Plague Doctor" : {
		"name" : "Plague Doctor",
		"position" : Vector2(1369,368),
		"dialogue_offset" : Vector2(-50,-180)
	}
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
	current_room = 1
	player.reset()
	level_changed.emit()
	
func check_game_over():
	if player.health <= 0:
		get_tree().change_scene_to_packed(gameOverScreen)

func increase_level():
	current_room += 1
	level_changed.emit()

func get_card(card_name : String) -> CardData:
	var filtered_cards = cards.filter(func(card : CardData) : return card._name == card_name)
	assert(filtered_cards.size() != 0, card_name + " not found !")
	assert(filtered_cards.size() < 2, "multiple cards with the name " + card_name + " found !")
	return filtered_cards[0].duplicate(true)
	
func get_enemy(enemy_name : String) -> EnemyData:
	var filtered_enemies = enemies.filter(func(enemy : EnemyData) : return enemy._name == enemy_name)
	assert(filtered_enemies.size() != 0, enemy_name + " not found !")
	assert(filtered_enemies.size() < 2, "multiple enemies with the name " + enemy_name + " found !")
	return filtered_enemies[0].duplicate(true)
	
func get_status_effect(status_effect_name : String,amount) -> StatusEffectData:
	var filtered_status_effects = status_effects.filter(func(effect : StatusEffectData) : return effect._name == status_effect_name)
	assert(filtered_status_effects.size() != 0, status_effect_name + " not found !")
	assert(filtered_status_effects.size() < 2, "multiple effects with the name " + status_effect_name + " found !")
	var new_effect = filtered_status_effects[0].duplicate(true)
	new_effect.amount = amount
	return new_effect

