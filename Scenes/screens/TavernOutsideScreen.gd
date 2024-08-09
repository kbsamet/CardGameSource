extends Control


var outline_material = preload("res://Shaders/outline.tres")
var tavernScene = preload("res://Scenes/screens/TavernScreen.tscn")
@onready var tavern = $Control/Tavern

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_control_mouse_entered():
	tavern.material = outline_material


func _on_control_mouse_exited():
	tavern.material = null


func _on_control_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			get_tree().change_scene_to_packed(tavernScene)
