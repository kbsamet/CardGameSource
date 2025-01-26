extends Resource
class_name CardData

@export var _name : String
@export var type : db.CardType
@export var description : String
@export var cost : int
@export var targeted : bool
@export var effects: Array[CardEffectData]
@export var is_rare : bool
@export var no_random_pool : bool


func is_damage_card() -> bool:
	for effect in effects:
		if effect.effect == db.CardEffect.Damage \
		or effect.effect == db.CardEffect.DamageAll \
		or effect.effect == db.CardEffect.Riposte:
			return true
	return false
	
