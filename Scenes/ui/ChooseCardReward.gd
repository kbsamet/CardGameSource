extends Control

signal card_chosen
@onready var cardContainer = $HBoxContainer
var cardScene = preload("res://Scenes/ui/RewardCard.tscn")
var outlineShader = preload("res://Shaders/outline.tres")
var cards : Array[CardData]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(3):
		var cards_copy : Array[CardData] = db.cards.duplicate(true)
		cards_copy = cards_copy.filter(func(card) : return card._name != "Strike" or card._name != "Block")
		var card_data = cards_copy.pick_random()
		while cards.filter(func(card): return card._name == card_data._name).size() != 0:
			card_data = cards_copy.pick_random()
		cards.push_back(card_data)
		var new_scene = cardScene.instantiate() as RewardCardScene
		cardContainer.add_child(new_scene)
		new_scene.set_data(card_data,i)
		new_scene.card_chosen.connect(_card_chosen)

func _card_chosen(id):
	db.player.add_to_deck(cards[id])
	card_chosen.emit()
