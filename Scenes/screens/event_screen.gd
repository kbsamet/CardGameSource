extends Node2D

@onready var ChooseRewardScene : PackedScene = load("res://Scenes/screens/RewardSelectScreen.tscn")
var events : Array[PackedScene] = [
	preload("res://Scenes/events/PotionEvent.tscn"),
	preload("res://Scenes/events/HouseEvent.tscn")
]

func _ready() -> void:
	var event_scene : Node
	if !db.saveData.hunter_done:
		events.insert(2,preload("res://Scenes/events/HunterEvent.tscn"))
	if !db.saveData.seen_hunter or "Wolf Pelt" in db.saveData.soulbound_cards:
		event_scene = events[2].instantiate()
	else:
		event_scene = events.pick_random().instantiate()
	add_child(event_scene)
	
func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(ChooseRewardScene)
