extends Control

@onready var cardContainer = $CardContainer
@onready var cardForSaleScene = preload("res://Scenes/ui/CardForSale.tscn")
@onready var tavernScene = preload("res://Scenes/screens/TavernScreen.tscn")
var chosen_cards = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	var cards_copy = db.cards.duplicate(true)
	cards_copy = cards_copy.filter(func(card): return card.type == db.CardType.Neutral)
	for i in range(3):
		var chosen_index = randi_range(0,cards_copy.size()-1)
		var chosen_card = cards_copy[chosen_index]
		chosen_cards[i] = chosen_card
		cards_copy.remove_at(chosen_index)
		var chosen_card_scene = cardForSaleScene.instantiate() as CardForSaleScene
		cardContainer.add_child(chosen_card_scene)
		chosen_card_scene.set_data(chosen_card,randi_range(10,20),i)
		chosen_card_scene.card_chosen.connect(_on_card_chosen)

func _on_card_chosen(id : int):
	var card_scenes = cardContainer.get_children()
	var chosen_card
	for card in card_scenes:
		if card.id == id:
			chosen_card = card
			break
	cardContainer.remove_child(chosen_card)
	chosen_card.queue_free()
	db.player.add_to_deck(chosen_card.card_data)
	db.player.gold -= chosen_card.price
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	db.clickPlayer.play()
	get_tree().change_scene_to_packed(tavernScene)
