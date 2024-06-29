extends Resource
class_name CardData

var _name : String
var type : db.CardType
var description : String
var cost : int
var targeted : bool
var effects: Dictionary

static func from_dict(card_data : Dictionary):
	var new_card = CardData.new()
	new_card._name = card_data["name"]
	new_card.type = card_data["type"]
	new_card.description = card_data["description"]
	new_card.cost = card_data["cost"]
	new_card.effects = card_data["effects"]
	new_card.targeted = card_data["targeted"]
	return new_card

static func from_card(card : CardData):
	var new_card = CardData.new()
	new_card._name = card._name
	new_card.type = card.type
	new_card.description = card.description
	new_card.cost = card.cost
	new_card.effects = card.effects.duplicate(true)
	new_card.targeted = card.targeted
	return new_card
