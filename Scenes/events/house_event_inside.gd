extends Control

@onready var gambler : Sprite2D = $Control/Gambler
@onready var outlineMaterial : ShaderMaterial = preload("res://Shaders/outline.tres")
var gambleScene : PackedScene = preload("res://Scenes/events/GambleScene.tscn")
var in_dialogue : bool = false
var dialogue : DialogueResource = preload("res://Dialogues/Gambler.dialogue")
var chosen_wager : String

func _on_control_mouse_entered() -> void:
	gambler.material = outlineMaterial

func _on_control_mouse_exited() -> void:
	gambler.material = null


func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() and !in_dialogue:
			db.clickPlayer.play()
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,dialogue,"start")
			balloon.dialogue_ended.connect(ended_dialogue)
			balloon.get_child(0).global_position = gambler.global_position + Vector2(200,-220)
			balloon.check_flip_response()
			in_dialogue = true

func set_chosen_wager(wager:String) -> void:
	chosen_wager = wager

func ended_dialogue() -> void:
	var gamble : GambleScene = gambleScene.instantiate()
	gamble.wager = chosen_wager
	get_tree().root.add_child(gamble)
	get_tree().current_scene = gamble
	queue_free()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		for n in get_children():
			if n is DialogueBalloon:
				n._on_balloon_gui_input(event)
