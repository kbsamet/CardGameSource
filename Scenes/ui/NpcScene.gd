extends Control
class_name NPCNode

signal started_dialogue
signal dialogue_ended
var dialogue_free : bool = true
@onready var sprite : Sprite2D = $Sprite
var data : NpcData
var outline_material : ShaderMaterial = preload("res://Shaders/outline.tres")
var dialogue : DialogueResource
func set_data(npc : NpcData) -> void:
	data = npc
	position = npc.postion
	sprite.texture = load("res://Sprites/ui/screens/npcs/"+npc._name+".png")
	dialogue = load("res://Dialogues/"+npc._name+".dialogue")

func _on_mouse_entered()-> void:
	sprite.material = outline_material


func _on_mouse_exited()-> void:
	sprite.material = null


func _on_gui_input(event : InputEvent)-> void:
	if event is InputEventMouseButton:
		if event.is_released() and dialogue_free:
			db.clickPlayer.play()
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,dialogue,"start")
			balloon.dialogue_ended.connect(func() -> void: dialogue_ended.emit())
			balloon.get_child(0).global_position = global_position + data.dialogue_offset
			balloon.check_flip_response()
			started_dialogue.emit()
