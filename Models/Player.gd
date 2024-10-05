extends Resource
class_name Player

var max_health : int = 30
var health : int = 30
var max_mana : int = 10
var mana : int = 10
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
var ability : AbilityData 
var gold : int = 10
var keys : int = 1

var next_turn_effects : Array[CardEffectData] = []

signal relics_changed

func add_relic(relic : RelicData,purchased: bool = false) -> void:
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
		"Gambler's Dice":
			add_player_status_effect("dodge_chance",10)
			add_player_status_effect("double_hit_chance",5)
		"Pocket Watch":
			add_player_status_effect("mana_carry_over",1)
		"The Letter":
			add_player_status_effect("heal_if_not_hit",2)
		"Morte":
			add_player_status_effect("empowered_overcharged",5)
		"Rock":
			add_player_status_effect("permanent_ignore_first_daze",1)
		"Scissors":
			add_player_status_effect("inflict_bleed_with_attack",1)
		"Hourglass":
			add_player_status_effect("boost_status_effects",2)
		"Mana Crystal":
			max_mana += 10
			max_health -= 5
			health = min(health,max_health)
			db.player_state_changed.emit()
			
		
	if purchased:
		gold -= relic.cost
	db.player_state_changed.emit()
	relics_changed.emit()

func use_ability() -> void:
	if mana < ability.cost:
		return
	match ability._name:
		"Empower":
			add_player_status_effect("empowered",2)
		"Enchant":
			add_player_status_effect("empowered",1)
			add_player_status_effect("block",2)
			
	mana -= ability.cost
	db.player_state_changed.emit()

func remove_relic(name : String) -> void:
	var filtered_relics : Array[RelicData] = relics.filter(func(relic : RelicData) -> bool: return relic._name == name)
	assert(filtered_relics.size() > 0, name + " not found in relics!")
	match name:
		"Blue Orb":
			add_max_ap(1)
			add_max_rp(-2)
		"Red Orb":
			add_max_ap(-1)
			hand_size += 1
		"Holy Cross":
			add_player_status_effect("revive_half",-1)
		"Iron Breastplate":
			add_player_status_effect("permanent_block",-5)
		"Minotaur's Horns":
			add_player_status_effect("permanent_empower",-3)
		"Gambler's Dice":
			add_player_status_effect("dodge_chance",-10)
			add_player_status_effect("double_hit_chance",-5)
		"Pocket Watch":
			add_player_status_effect("mana_carry_over",-1)
		"The Letter":
			add_player_status_effect("heal_if_not_hit",-2)
		"Morte":
			add_player_status_effect("empowered_overcharged",-5)
		"Rock":
			add_player_status_effect("permanent_ignore_first_daze",-1)
		"Scissors":
			add_player_status_effect("inflict_bleed_with_attack",-1)
		"Hourglass":
			add_player_status_effect("boost_status_effects",-2)
		"Mana Crystal":
			max_mana -= 10
			max_health += 5
			mana = min(mana,max_mana)
			db.player_state_changed.emit()
			
	relics.erase(filtered_relics[0])
	relics_changed.emit()
	db.player_state_changed.emit()

func add_player_items(item : String, amount: int) -> void:
	if item == "gold":
		gold += amount
	elif item == "key":
		keys += amount
	db.player_state_changed.emit()

func add_effect_next_turn(effect: CardEffectData) -> void:
	next_turn_effects.append(effect)

func heal_player(amount : int) -> void:
	health += amount
	health = min(max_health,health)
	db.player_state_changed.emit()

func restore_mana(amount:int) -> void:
	mana += amount
	mana = min(max_mana,mana)
	db.player_state_changed.emit()


func damage_player(amount: int,unblockable:bool = false)->void:
	var new_amount : int = amount
	if "double_hit_chance" in db.player.status_effects:
		if db.player.status_effects["double_hit_chance"].amount > randi_range(0,100):
			new_amount *= 2
	if !unblockable and ( "block" in status_effects and status_effects["block"].amount > 0):
		if status_effects.block.amount > new_amount:
			change_player_status_effect("block", status_effects.block.amount - new_amount)
			db.screen_effect.emit("blocked")
			return
		health = health - (new_amount - status_effects.block.amount)
		if (new_amount - status_effects.block.amount) != 0:
			db.screen_effect.emit("damaged")
		else:
			db.screen_effect.emit("blocked")
		if status_effects.block.amount != 0:
			change_player_status_effect("block", 0)
	else:
		health = health - new_amount
		if new_amount != 0:
			db.screen_effect.emit("damaged")
	db.player_state_changed.emit()
	db.check_game_over()
func add_player_status_effect(effect : String,amount: int,positive : bool = false) -> void:
	print("status effect: " + effect + " amount: " + str(amount))
	var new_amount:int = amount
	if positive and "boost_status_effects" in status_effects:
		new_amount += status_effects["boost_status_effects"].amount
	if effect == "dazed" and "ignore_first_daze" in status_effects:
		add_player_status_effect("ignore_first_daze",-1)
		return
	if effect in status_effects:
		if status_effects[effect].amount <= -new_amount:
			if effect == "give_ap":
				add_max_ap(-1)
			if effect == "give_rp":
				add_max_rp(-1)
			if effect == "drunk":
				add_max_ap(-1)
				add_max_rp(1)
			if effect == "tipsy" or effect == "drainAp":
				add_max_ap(1)
			if effect == "drainRp":
				add_max_rp(1)
			status_effects.erase(effect)
		else:
			if effect == "dazed" and new_amount > 0 and status_effects[effect].amount != 0:
				return
			status_effects[effect].amount += new_amount
	else:
		if new_amount < 0:
			return
		if effect == "give_ap":
			add_max_ap(1)
		if effect == "give_rp":
			add_max_rp(1)
		if effect == "drunk":
			add_max_ap(1)
			add_max_rp(-1)
		if effect == "tipsy" or effect == "drainAp":
			add_max_ap(-1)
		if effect == "drainRp":
			add_max_rp(-1)
			
		status_effects[effect] = db.get_status_effect(effect,new_amount)
	if effect == "block":
		if new_amount > 0:
			db.screen_effect.emit("gained_block")
		db.player_state_changed.emit()
	db.player_status_effect_changed.emit()

func swap_points() -> void:
	var prev_ap : int = ap
	ap = rp
	rp = prev_ap
	db.player_state_changed.emit()

func change_player_status_effect(effect:String,new_stat:int) -> void:
	if effect in status_effects:
		if new_stat == 0:
			status_effects.erase(effect)
		else:
			status_effects[effect].amount = new_stat
	else:
		if new_stat != 0:
			status_effects[effect] =  db.get_status_effect(effect,new_stat)
	if effect == "block":
		if new_stat > 0:
			db.screen_effect.emit("gained_block")
		db.player_state_changed.emit()
	db.player_status_effect_changed.emit()
	
func end_turn_process_player_status_effects() -> void:
	change_player_status_effect("block",0)
	change_player_status_effect("dodge",0)
	if "bleed" in status_effects:
		damage_player(status_effects["bleed"].amount)
		add_player_status_effect("bleed",-1)
	for effect in next_turn_effects:
		match effect.effect:
			db.CardEffect.Block:
				add_player_status_effect("block",effect.amount)
			db.CardEffect.LoseAllEmpowered:
				db.player.change_player_status_effect("empowered",0)
	next_turn_effects = []
func end_fight_process_player_status_effects() -> void:
	if "drunk" in db.player.status_effects:
		db.player.add_player_status_effect("drunk",-1)
	if "tipsy" in db.player.status_effects:
		db.player.add_player_status_effect("tipsy",-1)
	
	if "give_ap" in db.player.status_effects:
		db.player.add_player_status_effect("give_ap",-1)
	
	if "give_rp" in db.player.status_effects:
		db.player.add_player_status_effect("give_rp",-1)
	
	change_player_status_effect("block",0)
	change_player_status_effect("empowered",0)
	change_player_status_effect("dodge",0)
	change_player_status_effect("overcharged",0)
	change_player_status_effect("doubledamage",0)
func add_to_deck(card : CardData) -> void:
	deck.push_back(card)
	deck_size += 1
	db.player_state_changed.emit()

func purchase_item(item: String) -> void:
	var item_data : Dictionary = db.items[item]
	for effect : db.ItemEffect in item_data:
		match effect:
			db.ItemEffect.Heal:
				heal_player(item_data[effect])
			db.ItemEffect.Tipsy:
				add_player_status_effect("tipsy",item_data[effect])
			db.ItemEffect.Drunk:
				add_player_status_effect("drunk",item_data[effect])
			db.ItemEffect.Cost:
				add_player_items("gold",-item_data[effect])
			
func start_fight_effects() -> void:
	if "permanent_block" in status_effects:
		add_player_status_effect("block",status_effects["permanent_block"].amount)
	if "permanent_empower" in status_effects:
		add_player_status_effect("empowered",status_effects["permanent_empower"].amount)
	if "permanent_ignore_first_daze" in status_effects:
		add_player_status_effect("ignore_first_daze",status_effects["permanent_ignore_first_daze"].amount)
	
func reset() -> void:
	max_health = 30
	max_mana = 10
	health = max_health
	max_ap = 3
	max_rp = 3
	ap = max_ap
	rp = max_rp
	status_effects = {}
	deck = []
	discardPile = []
	gold = 10
	keys = 1
	relics = []
	mana = max_mana
	
	
# Relic funcs
func add_max_ap(amount : int) -> void:
	max_ap += amount
	ap = max_ap
	db.player_state_changed.emit()

func add_max_rp(amount : int) -> void:
	max_rp += amount
	rp = max_rp
	db.player_state_changed.emit()
	
	
	
