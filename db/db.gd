extends Node

@onready var background_music : PackedScene = preload("res://Sounds/Music/backgroundMusic.tscn")
@onready var clickPlayerScene : PackedScene = preload("res://Sounds/SFX/clickPlayer.tscn")
@onready var all_cards : ResourceGroup = preload("res://Resources/all_cards.tres")
@onready var all_status_effects : ResourceGroup = preload("res://Resources/all_status_effects.tres")
@onready var all_enemies : ResourceGroup = preload("res://Resources/all_enemies.tres")
@onready var all_relics : ResourceGroup = preload("res://Resources/all_relics.tres")
@onready var all_trials : ResourceGroup = preload("res://Resources/all_trials.tres")
@onready var all_abilities : ResourceGroup = preload("res://Resources/all_abilities.tres")

var weatherScene : PackedScene = preload("res://Scenes/screens/Weather.tscn")
var pauseScreen : PackedScene = preload("res://Scenes/ui/PauseScreen.tscn")
var activePauseScreen : PauseScreen

var cards : Array[CardData] 
var status_effects : Array[StatusEffectData]
var enemies : Array[EnemyData]
var relics : Array[RelicData]
var trials : Array[TrialData]
var abilities : Array[AbilityData]

var weather : Weather
var weather_level : int = 2
var saveData : SaveData
var settingsData : SettingsData
var clickPlayer : AudioStreamPlayer
var run_time : float = 0.0
var run_started : bool = false
var music : AudioStreamPlayer

func _ready() -> void:
	DialogueManager.DialogueSettings.set_setting("balloon_path","res://Dialogues/balloon.tscn")
	all_cards.load_all_into(cards)
	all_status_effects.load_all_into(status_effects)
	all_enemies.load_all_into(enemies)
	all_relics.load_all_into(relics)
	all_trials.load_all_into(trials)
	all_abilities.load_all_into(abilities)
	var click : AudioStreamPlayer = clickPlayerScene.instantiate()
	add_child(click)
	clickPlayer = click
	weather = weatherScene.instantiate()
	add_child(weather)
	music = background_music.instantiate() 
	add_child(music)
	music.play()
	player.ability = get_ability("Enchant")
	saveData = SaveData.load_save()
	settingsData = SettingsData.load_settings()
	apply_settings()

func start_weather(weather_type : String) -> void:
	if weather_level == 0:
		return
	weather.start(weather_type + str(weather_level))

func change_weather_level() -> void:
	var diff : int = randi_range(0,1) * 2 - 1
	weather_level = min(3,max(0,diff))
	if weather_level == 0:
		stop_weather()
	else:
		if current_stage == 0:
			start_weather("rain" if current_stage == 0 else "snow")

func stop_weather() -> void:
	weather.stop()

func _process(delta : float) -> void:
	if player.health > 0 and run_started:
		run_time += delta
	if Input.is_action_just_released("ui_escape"):
		pause()
		
func pause() -> void:
	if !get_tree().paused:
		print("pausing")
		var p : PauseScreen = pauseScreen.instantiate()
		activePauseScreen = p
		get_parent().add_child(p)
		get_tree().paused = true
func unpause() -> void:
	print("unpausing")
	get_parent().remove_child(activePauseScreen)
	activePauseScreen.queue_free()
	get_tree().paused = false

func percent_to_db(percent: float) -> float:
	if percent <= 0:
		return -80.0  # Return lowest possible dB (silence)
	return 20.0 * log(percent / 100.0) / log(10.0)

# Function to apply volume settings
func apply_volume_settings() -> void:
	var sfx_bus_idx := AudioServer.get_bus_index("sfx")
	var music_bus_idx := AudioServer.get_bus_index("Music")

	AudioServer.set_bus_volume_db(sfx_bus_idx, percent_to_db(settingsData.sfxVolume))
	AudioServer.set_bus_volume_db(music_bus_idx, percent_to_db(settingsData.musicVolume))
	
func apply_settings() -> void:
	apply_volume_settings()
	
signal level_changed
signal player_state_changed
signal player_status_effect_changed
signal ability_effect(effect :String, amount : int)
signal screen_effect(effect : String)
signal turn_changed(new_turn : Turn)
signal player_dead

var player : Player = Player.new()
var current_room : int = 1
var current_stage : int = 0
var current_turn : Turn = Turn.PlayerAction


enum Turn {
	PlayerAction,PlayerReaction, EnemyAction,EnemyReaction
}

enum CardType {
	Action,Reaction,Neutral
} 

enum CardEffect {
	Damage,Block,Dodge,Daze,Bleed,Heal,DamageAll,ConvertAllAp,ConvertAllRp,Crushing,ShieldSlam,Riposte,Draw,
	Empower,DiscardRandom,GainAp,GainRp,NoManaNextTurn,SwapActionReaction,DoubleDamageTurn,BleedAll,
	BarbedArmor,GainApOnKill,DamageIfEnemyBleeding,DiscardAllReactionDrawEqual,BlockIfNoOtherReactionCards,DamageSelf,
	GainEmpoweredOnKill,DoubleEmpowered,LoseAllEmpowered,GainMana,DamageEqualToMana,BlockEqualToMana,Energize,
	CounterAttack,DoNotDiscard
}

enum EnemyAttack {
	Bleed,Damage,StaminaCost,Daze,Blind,ArmorUp,HealAll,Unstoppable,Burn,Empower,Lifesteal,Unblockable,DrainAp,DrainRp,
	GainStamina,Cripple,Silence
}

enum ItemEffect {
	Heal,RestoreMana,Drunk,Tipsy,Cost
}

const card_keywords = [
	"block","dodge","daze","bleed","crushing","empowered","overcharged","barbed armor"
]

var enemy_tooltips : Dictionary = {
	db.EnemyAttack.Damage : "Damage:Deal _ damage.",
	db.EnemyAttack.Bleed :  "Bleed:_ damage per turn for _ turns.",
	db.EnemyAttack.StaminaCost: "Cost:This attack will cost _ stamina.",
	db.EnemyAttack.Daze : "Daze:You will be unable to attack for _ turns.",
	db.EnemyAttack.ArmorUp: "Armor Up:This enemy will gain _ block.",
	db.EnemyAttack.HealAll: "Heal All:This enemy will heal all enemies by _.",
	db.EnemyAttack.Blind: "Blind:You will be unable to target enemies for _ turns.",
	db.EnemyAttack.Burn: "Burn:You will discard a random card for _ turns.",
	db.EnemyAttack.Unstoppable: "Unstoppable:This enemy will be unable to be stunned for _ turns.",
	db.EnemyAttack.Empower: "Empower:This enemy will do _ more damage.",
	db.EnemyAttack.Lifesteal: "Lifesteal:Deal _ damage. Heal _ health.",
	db.EnemyAttack.Unblockable: "Unblockable:This attack cannot be blocked.",
	db.EnemyAttack.DrainAp: "Drain AP:Lose 1 ap for _ turns.",
	db.EnemyAttack.DrainRp: "Drain RP:Lose 1 rp for _ turns.",
	db.EnemyAttack.GainStamina : "Gain Stamina:This enemy will recover _ stamina",
	db.EnemyAttack.Cripple : "Cripple:You will deal _ less damage.",
	db.EnemyAttack.Silence : "Silence:You will be unable to use your ability for _ turns."
}

const card_tooltips : Dictionary = {
	CardEffect.Block : "Block:Block _ damage for this turn.",
	CardEffect.Dodge : "Dodge:Dodge the incoming attack.",
	CardEffect.Daze : "Daze:The enemy will be unable to attack for _ turns.",
	CardEffect.Bleed : "Bleed:The enemy will receive _ damage per turn.",
	CardEffect.Crushing : "Crushing:Deal double damage to dazed enemies for _ turns.",
	CardEffect.Empower : "Empower:Your attacks will do _ more damage.",
	CardEffect.NoManaNextTurn : "Overcharged:You wil lose 5 mana next turn. If you don't have enough mana you will be dazed.",
	CardEffect.BarbedArmor : "Barbed Armor:Bleed is inflicted on attacking enemies equal to the damage you blocked.",
	CardEffect.BleedAll : "Bleed:The enemy will receive _ damage per turn.",
	CardEffect.CounterAttack : "Counter Attack:After dodging deal the dodged damage amount to the enemy."
}

const dialogue_tooltips : Dictionary = {
	"beer" : "Beer:Restore 5 health.",
	"wine" : "Wine:Restore 10 health. Restore 5 mana.",
	"whiskey" : "Whiskey:Restore 15 health. Restore 10 mana. Gain +1 max ap and +1 max rp for 3 fights."
}

const items : Dictionary = {
	"beer" : {
		ItemEffect.Heal : 5,
		ItemEffect.Cost : 10
	},
	"wine" : {
		ItemEffect.Heal : 10,
		ItemEffect.RestoreMana : 5,
		ItemEffect.Cost : 20
	},
	"whiskey" : {
		ItemEffect.Heal : 15,
		ItemEffect.RestoreMana: 10,
		ItemEffect.Drunk: 3,
		ItemEffect.Cost : 30
	}
}


const rewards : Array[Dictionary] = [
	#{
		#"reward" : "gold",
		#"amount" : "10-15",
		#"tooltip" : "Gain gold after the next fight.",
		#"multiplier": 3
	#},
	{
		"reward" : "key",
		"amount" : 1,
		"tooltip" : "Gain a key after the next fight.",
		"multiplier": 2
	},
	{
		"reward" : "locked_chest",
		"amount" : 1,
		"tooltip" : "There is a locked chest after the next fight.",
		"multiplier": 4
		
	},
	{
		"reward" : "choose_card",
		"amount" : 3,
		"tooltip" : "Choose one of 3 cards after the next fight.",
		"multiplier": 5
		
	},
	{
		"reward" : "event",
		"amount" : 1,
		"tooltip" : "There is a random event after the next fight.",
		"multiplier": 2
		
	},
	{
		"reward" : "choose_relic",
		"amount" : 3,
		"tooltip" : "Choose one of 3 relics after the next fight.",
		"multiplier": 1
		
	},
	{
		"reward" : "campfire",
		"amount" : 1,
		"tooltip" : "Have a chance to rest or train after the next fight.",
		"multiplier": 3
		
	},
	{
		"reward" : "tavern",
		"amount" : 1,
		"tooltip" : "There is a tavern after the next fight.",
		"multiplier": 0
		
	},
	{
		"reward" : "choose_rare_card",
		"amount" : 3,
		"tooltip" : "Choose one of 3 rare cards after the next fight.",
		"multiplier": 0
		
	},
]

const boss_rewards: Array[Dictionary] = [
	{
		"reward" : "choose_rare_card",
		"amount" : 3,
		"tooltip" : "Choose one of 3 rare cards after the next fight.",
		"multiplier": 1
		
	},
	#{
		#"reward" : "gain_blessing",
		#"amount" : 1,
		#"tooltip" : "Gain a blessing after the next fight.",
		#"multiplier": 1
		#
	#},
	{
		"reward" : "choose_relic",
		"amount" : 3,
		"tooltip" : "Choose one of 3 relics after the next fight.",
		"multiplier": 1
	}
]

const locked_chest_rewards : Array[Dictionary] = [
	{
		"reward": "gold",
		"amount": "25-30",
		"multiplier" : 3
	},
	{
		"reward": "choose_rare_card",
		"amount": 3,
		"multiplier" : 2
	},
	{
		"reward": "choose_relic",
		"amount": 3,
		"multiplier" : 1
	},
	
]

var npcs : Dictionary = {
	"Bartender" : {
		"name" : "Bartender",
		"position" : Vector2(74,309),
		"dialogue_offset" : Vector2(220,0)

	},
	"Wizard" : {
		"name" : "Wizard",
		"position" : Vector2(1149,192),
		"dialogue_offset" : Vector2(-100,-130),
		"questionsAsked" : false
	},
	"Plague Doctor" : {
		"name" : "Plague Doctor",
		"position" : Vector2(1369,368),
		"dialogue_offset" : Vector2(-50,-180)
	},
	"Merchant" : {
		"name" : "Merchant",
		"position" : Vector2(562,466),
		"dialogue_offset" : Vector2(0,-350)
	}
}

func setup_merchant_shop() -> void:
	var relics : Array[RelicData] = []
	var relics_copy : Array[RelicData] = db.relics.duplicate(true).filter(func(relic: RelicData) -> bool : return !db.player.relics.has(relic) and !relic.no_random_pool)
	for i in range(3):
		var chosen_index : int = randi_range(0,relics_copy.size()-1)
		var relic_data : RelicData = relics_copy[chosen_index]
		relics.push_back(relic_data)
		relics_copy.remove_at(chosen_index)
	db.npcs["Merchant"].relics = relics

func remove_from_deck(card_index : int) -> void:
	player.deck.remove_at(card_index)
	player_state_changed.emit()
	
func set_turn(newTurn : Turn) -> void:
	current_turn = newTurn
	turn_changed.emit(newTurn)

func  reset_player() -> void:
	current_room = 1
	current_stage = 1
	current_turn = Turn.PlayerAction
	player.reset()
	level_changed.emit()
	
func check_game_over() -> void:
	if player.health <= 0:
		if "revive_half" in player.status_effects:
			player.health = player.max_health / 2
			player.remove_relic("Holy Cross")
			player_state_changed.emit()
			return
		player_dead.emit()

func increase_level() -> void:
	current_room += 1
	level_changed.emit()

func get_card(card_name : String) -> CardData:
	var filtered_cards : Array[CardData] = cards.filter(func(card : CardData) -> bool : return card._name == card_name)
	assert(filtered_cards.size() != 0, card_name + " not found !")
	assert(filtered_cards.size() < 2, "multiple cards with the name " + card_name + " found !")
	return filtered_cards[0].duplicate(true)
	
func get_enemy(enemy_name : String) -> EnemyData:
	var filtered_enemies: Array[EnemyData] = enemies.filter(func(enemy : EnemyData) -> bool: return enemy._name == enemy_name)
	assert(filtered_enemies.size() != 0, enemy_name + " not found !")
	assert(filtered_enemies.size() < 2, "multiple enemies with the name " + enemy_name + " found !")
	return filtered_enemies[0].duplicate(true)
	
func get_reward(reward_name : String) -> RewardData:
	var filtered_rewards: Array[Dictionary] = rewards.filter(func(reward : Dictionary) -> bool: return reward.reward == reward_name)
	assert(filtered_rewards.size() != 0, reward_name + " not found !")
	assert(filtered_rewards.size() < 2, "multiple rewards with the name " + reward_name + " found !")
	return RewardData.fromDict(filtered_rewards[0])
	
func get_ability(ability_name : String) -> AbilityData:
	var filtered_abilities: Array[AbilityData] = abilities.filter(func(ability : AbilityData) -> bool: return ability._name == ability_name)
	assert(filtered_abilities.size() != 0, ability_name + " not found !")
	assert(filtered_abilities.size() < 2, "multiple abilities with the name " + ability_name + " found !")
	return filtered_abilities[0].duplicate(true)
	
func get_relic(relic_name : String) -> RelicData:
	var filtered_relics: Array[RelicData] = relics.filter(func(relic : RelicData) -> bool: return relic._name == relic_name)
	assert(filtered_relics.size() != 0, relic_name + " not found !")
	assert(filtered_relics.size() < 2, "multiple relics with the name " + relic_name + " found !")
	return filtered_relics[0].duplicate(true)
		
func get_status_effect(status_effect_name : String,amount:int) -> StatusEffectData:
	var filtered_status_effects : Array[StatusEffectData] = status_effects.filter(func(effect : StatusEffectData) -> bool : return effect._name == status_effect_name)
	assert(filtered_status_effects.size() != 0, status_effect_name + " not found !")
	assert(filtered_status_effects.size() < 2, "multiple effects with the name " + status_effect_name + " found !")
	var new_effect : StatusEffectData = filtered_status_effects[0].duplicate(true)
	new_effect.amount = amount
	return new_effect
