extends Resource
class_name CardData

@export var _name : String
@export var type : db.CardType
@export var description : String
@export var cost : int
@export var targeted : bool
@export var effects: Array[CardEffectData]

static func from_card(card : CardData):
	var new_card = CardData.new()
	new_card._name = card._name
	new_card.type = card.type
	new_card.description = card.description
	new_card.cost = card.cost
	new_card.effects = card.effects.duplicate(true)
	new_card.targeted = card.targeted
	return new_card
