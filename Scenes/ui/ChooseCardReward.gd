extends Control
class_name ChooseCardScene
signal card_chosen
@onready var cardContainer : HBoxContainer= $HBoxContainer
var cardScene : PackedScene = preload("res://Scenes/ui/RewardCard.tscn")
var outlineShader : ShaderMaterial = preload("res://Shaders/outline.tres")
var cards : Array[CardData]
var rare_only : bool = false
@export var disable_button_and_text : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.visible = !disable_button_and_text
	$Button.disabled = disable_button_and_text
	$Button.visible = !disable_button_and_text
	var cards_copy : Array[CardData] = db.cards.duplicate(true)
	cards_copy = cards_copy.filter(func(card : CardData) -> bool : return card._name != "Strike" and card._name != "Block" and card.type != db.CardType.Neutral)
	if rare_only:
		cards_copy = cards_copy.filter(func(card : CardData) -> bool : return card.is_rare)
	for i in range(3):
		var card_data : CardData = cards_copy.pick_random()
		while card_data.is_rare:
			if randf() > 0.9:
				break
			else:
				card_data = cards_copy.pick_random()
		cards.push_back(card_data)
		cards_copy.erase(card_data)
		var new_scene : RewardCardScene = cardScene.instantiate()
		cardContainer.add_child(new_scene)
		new_scene.set_data(card_data,i)
		new_scene.card_chosen.connect(_card_chosen)
	if cards.filter(func(card:CardData) -> bool : return card.type == db.CardType.Action).size() == 0:
		cards_copy = cards_copy.filter(func(card:CardData) -> bool: return card.type == db.CardType.Action)
		cards.remove_at(0)
		cards.push_back(cards_copy.pick_random())
	elif cards.filter(func(card:CardData) -> bool : return card.type == db.CardType.Reaction).size() == 0:
		cards_copy = cards_copy.filter(func(card:CardData) -> bool: return card.type == db.CardType.Reaction)
		cards.remove_at(0)
		cards.push_back(cards_copy.pick_random())
func _card_chosen(id : int)-> void:
	db.player.add_to_deck(cards[id])
	card_chosen.emit()


func _on_button_pressed()-> void:
	db.clickPlayer.play()
	card_chosen.emit()
