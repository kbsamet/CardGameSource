extends Control


var outline_material : ShaderMaterial = preload("res://Shaders/outline.tres")
var tavernScene : PackedScene = preload("res://Scenes/screens/TavernScreen.tscn")
@onready var tavern : Sprite2D = $Control/Tavern

func _on_control_mouse_entered() -> void:
	tavern.material = outline_material


func _on_control_mouse_exited() -> void:
	tavern.material = null


func _on_control_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			get_tree().change_scene_to_packed(tavernScene)
