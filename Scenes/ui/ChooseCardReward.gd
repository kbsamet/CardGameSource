extends Control

signal card_chosen
@onready var cardContainer = $HBoxContainer
var cardScene = preload("res://Scenes/ui/RewardCard.tscn")
var outlineShader = preload("res://Shaders/outline.tres")
var cards : Array[CardData]
var rare_only = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var cards_copy : Array[CardData] = db.cards.duplicate(true)
	cards_copy = cards_copy.filter(func(card) : return card._name != "Strike" and card._name != "Block" and card.type != db.CardType.Neutral)
	if rare_only:
		cards_copy = cards_copy.filter(func(card) : return card.is_rare)
	for i in range(3):
		var card_data = cards_copy.pick_random()
		while card_data.is_rare:
			if randf() > 0.9:
				break
			else:
				card_data = cards_copy.pick_random()
		cards.push_back(card_data)
		cards_copy.erase(card_data)
		var new_scene = cardScene.instantiate() as RewardCardScene
		cardContainer.add_child(new_scene)
		new_scene.set_data(card_data,i)
		new_scene.card_chosen.connect(_card_chosen)

func _card_chosen(id):
	db.player.add_to_deck(cards[id])
	card_chosen.emit()


func _on_button_pressed():
	db.clickPlayer.play()
	card_chosen.emit()
