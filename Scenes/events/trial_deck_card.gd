extends Control
class_name TrialDeckCardScene
var card_data : CardData
var id: int
@onready var cardBackSprite : Sprite2D = $CardBack
var rewardCardScene : PackedScene = preload("res://Scenes/ui/RewardCard.tscn")
var flipped : bool = false

signal card_flipped(id:int)
func set_data(data:CardData,_id : int) -> void:
	card_data = data
	id = _id

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() and !flipped:
			var cardScene : RewardCardScene = rewardCardScene.instantiate()
			add_child(cardScene)
			cardScene.position = Vector2(0,0)
			cardScene.set_data(card_data,id)
			cardBackSprite.visible = false
			flipped = true
			card_flipped.emit(id)
			
