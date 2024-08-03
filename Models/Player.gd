extends Resource
class_name Player

var max_health : int = 20
var health : int = 20
var max_ap : int = 3
var ap : int = 3
var rp : int = 3
var max_rp : int = 3
var hand_size : int = 6
var deck_size : int = 10
var status_effects : Dictionary = {}
var deck : Array[CardData] = []
var discardPile : Array[CardData] = []
var relics : Array[RelicData] = []
var gold : int = 0
var keys : int = 1

signal relics_changed

func add_relic(relic : RelicData,purchased: bool = false):
	relics.push_back(relic)
	match relic._name:
		"Blue Orb":
			add_max_ap(-1)
			add_max_rp(2)
		"Red Orb":
			add_max_ap(1)
			hand_size -= 1
		"Holy Cross":
			add_player_status_effect("revive_half",1)
		"Iron Breastplate":
			add_player_status_effect("permanent_block",5)
		"Minotaur's Horns":
			add_player_status_effect("permanent_empower",3)
	if purchased:
		gold -= relic.cost
	db.player_state_changed.emit()
	relics_changed.emit()
	
func remove_relic(name : String):
	var filtered_relics = relics.filter(func(relic): return relic._name == name)
	assert(filtered_relics.size() > 0, name + " not found in relics!")
	if name == "Holy Cross":
		add_player_status_effect("revive_half",-1)
	relics.erase(filtered_relics[0])
	relics_changed.emit()
	db.player_state_changed.emit()
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
	if "block" in status_effects and status_effects["block"].amount > 0:
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
	print("status effect: " + effect + " amount: " + str(amount))
	if effect in status_effects:
		if status_effects[effect].amount == -amount:
			if effect == "drunk":
				add_max_ap(-1)
				add_max_rp(1)
			if effect == "tipsy":
				add_max_ap(1)
			status_effects.erase(effect)
		else:
			status_effects[effect].amount += amount
	else:
		if effect == "drunk":
			add_max_ap(1)
			add_max_rp(-1)
		if effect == "tipsy":
			add_max_ap(-1)
		status_effects[effect] = db.get_status_effect(effect,amount)
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
		status_effects[effect] =  db.get_status_effect(effect,new_stat)
	if effect == "block":
		db.player_state_changed.emit()
	db.player_status_effect_changed.emit()
	
func end_turn_process_player_status_effects():
	change_player_status_effect("block",0)
	if "bleed" in status_effects:
		damage_player(status_effects["bleed"].amount)
		add_player_status_effect("bleed",-1)

func end_fight_process_player_status_effects():
	if "drunk" in db.player.status_effects:
		db.player.add_player_status_effect("drunk",-1)
	if "tipsy" in db.player.status_effects:
		db.player.add_player_status_effect("tipsy",-1)
	
	change_player_status_effect("block",0)
	change_player_status_effect("empowered",0)
	change_player_status_effect("dodge",0)
	
func add_to_deck(card : CardData):
	deck.push_back(card)
	deck_size += 1
	db.player_state_changed.emit()

func purchase_item(item: String):
	var item_data = db.items[item]
	for effect in item_data:
		match effect:
			db.ItemEffect.Heal:
				heal_player(item_data[effect])
			db.ItemEffect.Tipsy:
				add_player_status_effect("tipsy",item_data[effect])
			db.ItemEffect.Drunk:
				add_player_status_effect("drunk",item_data[effect])
			db.ItemEffect.Cost:
				add_player_items("gold",-item_data[effect])
			
func start_fight_effects():
	if "permanent_block" in status_effects:
		add_player_status_effect("block",status_effects["permanent_block"].amount)
	if "permanent_empower" in status_effects:
		add_player_status_effect("empowered",status_effects["permanent_empower"].amount)
		
	
func reset():
	health = max_health
	ap = max_ap
	rp = max_rp
	status_effects = {}
	deck = []
	discardPile = []
	gold = 0
	keys = 1
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
	
	
	
