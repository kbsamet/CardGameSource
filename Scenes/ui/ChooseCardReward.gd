extends Control

signal card_chosen

@onready var cardSprite = $HBoxContainer/CardControl/Card
@onready var card2Sprite = $HBoxContainer/Card2Control/Card2
@onready var card3Sprite = $HBoxContainer/Card3Control/Card3
@onready var cardControl = $HBoxContainer/CardControl
@onready var card2Control = $HBoxContainer/Card2Control
@onready var card3Control = $HBoxContainer/Card3Control
@onready var cardMana = $HBoxContainer/CardControl/ManaLabel
@onready var card2Mana = $HBoxContainer/Card2Control/ManaLabel
@onready var card3Mana = $HBoxContainer/Card3Control/ManaLabel
@onready var cardType = $HBoxContainer/CardControl/TypeLabel
@onready var card2Type = $HBoxContainer/Card2Control/TypeLabel
@onready var card3Type = $HBoxContainer/Card3Control/TypeLabel
@onready var cardName = $HBoxContainer/CardControl/NameLabel
@onready var card2Name = $HBoxContainer/Card2Control/NameLabel
@onready var card3Name = $HBoxContainer/Card3Control/NameLabel
@onready var cardDescription = $HBoxContainer/CardControl/DescriptionLabel
@onready var card2Description = $HBoxContainer/Card2Control/DescriptionLabel
@onready var card3Description = $HBoxContainer/Card3Control/DescriptionLabel



var outlineShader = preload("res://Shaders/outline.tres")
var cards : Array[CardData]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(3):
		var card_data = CardData.from_dict(db.cards.values().pick_random())
		while cards.filter(func(card): return card._name == card_data._name).size() != 0:
			card_data = CardData.from_dict(db.cards.values().pick_random())
		cards.push_back(card_data)
	cardSprite.texture = load("res://Sprites/cards/"+cards[0]._name+".png")
	card2Sprite.texture = load("res://Sprites/cards/"+cards[1]._name+".png")
	card3Sprite.texture = load("res://Sprites/cards/"+cards[2]._name+".png")
	
	cardMana.text = str(cards[0].cost)
	card2Mana.text = str(cards[1].cost)
	card3Mana.text = str(cards[2].cost)
	
	cardType.text = "A" if cards[0].type == db.CardType.Action else "R"
	card2Type.text = "A" if cards[1].type == db.CardType.Action else "R"
	card3Type.text = "A" if cards[2].type == db.CardType.Action else "R"
	 
	
	cardName.text = cards[0]._name
	card2Name.text = cards[1]._name
	card3Name.text = cards[2]._name
	
	cardDescription.text = cards[0].description
	card2Description.text = cards[1].description
	card3Description.text = cards[2].description
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_card2_mouse_entered():
	card2Sprite.material = outlineShader


func _on_card2_mouse_exited():
	card2Sprite.material = null


func _on_card_mouse_entered():
	cardSprite.material = outlineShader


func _on_card_mouse_exited():
	cardSprite.material = null


func _on_card3_mouse_entered():
	card3Sprite.material = outlineShader


func _on_card3_mouse_exited():
	card3Sprite.material = null


func _on_card2_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			db.player.add_to_deck(cards[1])
			card_chosen.emit()


func _on_card_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			db.player.add_to_deck(cards[0])
			card_chosen.emit()


func _on_card3_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			db.player.add_to_deck(cards[2])
			card_chosen.emit()
