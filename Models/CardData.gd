extends Resource
class_name CardData

@export var _name : String
@export var type : db.CardType
@export var description : String
@export var cost : int
@export var targeted : bool
@export var effects: Array[CardEffectData]

func is_damage_card() -> bool:
	for effect in effects:
		if effect.effect == db.CardEffect.Damage \
		or effect.effect == db.CardEffect.DamageAll \
		or effect.effect == db.CardEffect.Riposte:
			return true
	return false
	
static func from_card(card : CardData):
	var new_card = CardData.new()
	new_card._name = card._name
	new_card.type = card.type
	new_card.description = card.description
	new_card.cost = card.cost
	new_card.effects = card.effects.duplicate(true)
	new_card.targeted = card.targeted
	return new_card
