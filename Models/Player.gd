extends Resource
class_name Player

var max_health : int = 20
var health : int = 20
var max_ap : int = 3
var ap : int = 3
var rp : int = 3
var max_rp : int = 3
var hand_size : int = 5
var deck_size : int = 10
var status_effects : Dictionary = {}
var deck : Array[CardData] = []
var discardPile : Array[CardData] = []
var relics : Array[RelicData] = []
var gold : int = 0
var keys : int = 0

signal relics_changed

func add_relic(relic : RelicData):
	relics.push_back(relic)
	relic.on_add.call(self)
	db.player_state_changed.emit()
	relics_changed.emit()

func add_player_items(item,amount):
	if item == "gold":
		gold += amount
	elif item == "key":
		keys += amount
	db.player_state_changed.emit()

func heal_player(amount):
	health += amount
	health = min(max_health,health)
	db.player_state_changed.emit()

func damage_player(amount):
	if "block" in status_effects:
		if status_effects.block.amount > amount:
			change_player_status_effect("block", status_effects.block.amount - amount)
			return
		health = health - (amount - status_effects.block.amount)
		if status_effects.block.amount != 0:
			change_player_status_effect("block", 0)
	else:
		health = health - amount
	db.player_state_changed.emit()

func add_player_status_effect(effect : String,amount: int):
	if effect in status_effects:
		if status_effects[effect].amount == -amount:
			status_effects.erase(effect)
		else:
			status_effects[effect].amount += amount
	else:
		status_effects[effect] = StatusEffectData.fromDict(db.status_effects[effect],amount)
	if effect == "block":
		db.player_state_changed.emit()
	db.player_status_effect_changed.emit()
	
func change_player_status_effect(effect:String,new_stat:int):
	if effect in status_effects:
		if new_stat == 0:
			status_effects.erase(effect)
		else:
			status_effects[effect].amount = new_stat
	else:
		status_effects[effect] = StatusEffectData.fromDict(db.status_effects[effect],new_stat)
	if effect == "block":
		db.player_state_changed.emit()
	db.player_status_effect_changed.emit()
	
func end_turn_process_player_status_effects():
	change_player_status_effect("block",0)
	if "bleed" in status_effects:
		damage_player(status_effects["bleed"].amount)
		add_player_status_effect("bleed",-1)

func add_to_deck(card : CardData):
	deck.push_back(card)
	deck_size += 1
	db.player_state_changed.emit()

func purchase_item(item: String):
	print("purchased " + item)

func reset():
	health = max_health
	ap = max_ap
	rp = max_rp
	status_effects = {}
	deck = []
	discardPile = []
	gold = 0
	keys = 0
	relics = []
	
	
# Relic funcs
func add_max_ap(amount : int):
	max_ap += amount
	ap = max_ap
	db.player_state_changed.emit()

func add_max_rp(amount : int):
	max_rp += amount
	rp = max_rp
	db.player_state_changed.emit()
	
	
	
