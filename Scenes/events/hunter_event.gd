extends Control

@onready var dialogue : DialogueResource = preload("res://Dialogues/Hunter.dialogue")
@onready var hunter : Sprite2D = $Hunter
func _ready() -> void:
	db.saveData.seen_hunter = true
	db.saveData.save_game()
	await get_tree().create_timer(1)
	db.weather_level = min(3,db.weather_level+1)
	db.start_weather("rain")
	var balloon : Node = DialogueManager.show_dialogue_balloon(self,dialogue,"start")
	balloon.dialogue_ended.connect(ended_dialogue)
	balloon.get_child(0).global_position = hunter.global_position + Vector2(-280,-150)


func ended_dialogue() -> void:
	pass


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		for n in get_children():
			if n is DialogueBalloon:
				n._on_balloon_gui_input(event)
