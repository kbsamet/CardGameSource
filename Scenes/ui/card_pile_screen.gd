extends Control
class_name CardPileScreen
@onready var grid : GridContainer = $ScrollContainer/GridContainer
@onready var cardScene : PackedScene = preload("res://Scenes/ui/RewardCard.tscn")

func set_data(cards : Array[CardData])-> void:
	for card in grid.get_children():
		grid.remove_child(card)
	for card in cards:
		var new_card : RewardCardScene = cardScene.instantiate()
		grid.add_child(new_card)
		new_card.set_data(card,0,true)


func _on_button_pressed()-> void:
	visible = false
