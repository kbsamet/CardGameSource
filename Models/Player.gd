extends Resource
class_name Player

var max_health : int = 20
var health : int = 20
var max_ap : int = 2
var ap : int = 2
var rp : int = 2
var max_rp : int = 2
var hand_size : int = 5
var deck_size : int = 10
var status_effects : Dictionary = {}
var deck : Array[CardData] = []
var discardPile : Array[CardData] = []

func damage_player(amount):
	if "block" in status_effects:
		if status_effects.block > amount:
			change_player_status_effect("block", status_effects.block - amount)
			return
		health = health - (amount - status_effects.block)
		if status_effects.block != 0:
			change_player_status_effect("block", 0)
	else:
		health = health - amount
	db.player_state_changed.emit()

func add_player_status_effect(effect,amount):
	if effect in status_effects:
		if status_effects[effect] == -amount:
			status_effects.erase(effect)
		else:
			status_effects[effect] += amount
	else:
		status_effects[effect] = amount
	db.player_status_effect_changed.emit()
	
func change_player_status_effect(effect,new_stat):
	if new_stat == 0:
		status_effects.erase(effect)
	else:
		status_effects[effect] = new_stat
	db.player_status_effect_changed.emit()
	
func end_turn_process_player_status_effects():
	change_player_status_effect("block",0)
	if "bleed" in status_effects:
		damage_player(1)
		add_player_status_effect("bleed",-1)

func reset():
	health = max_health
	ap = max_ap
	rp = max_rp
	status_effects = {}
	deck = []
	discardPile = []
