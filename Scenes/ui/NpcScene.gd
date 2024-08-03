extends Control
class_name NPCNode

signal started_dialogue
signal dialogue_ended
var dialogue_free = true
@onready var sprite = $Sprite
var data : NpcData
var outline_material = preload("res://Shaders/outline.tres")
var dialogue 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_data(npc : NpcData):
	data = npc
	position = npc.postion
	sprite.texture = load("res://Sprites/ui/screens/npcs/"+npc._name+".png")
	dialogue = load("res://Dialogues/"+npc._name+".dialogue")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	sprite.material = outline_material


func _on_mouse_exited():
	sprite.material = null


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_released() and dialogue_free:
			db.clickPlayer.play()
			var balloon = DialogueManager.show_dialogue_balloon(self,dialogue,"start")
			balloon.dialogue_ended.connect(func(): dialogue_ended.emit())
			balloon.get_child(0).global_position = global_position + data.dialogue_offset
			balloon.check_flip_response()
			started_dialogue.emit()
