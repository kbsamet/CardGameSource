extends Control

@onready var door : Sprite2D = $Control/Door
@onready var outlineMaterial : ShaderMaterial = preload("res://Shaders/outline.tres")
@onready var house_inside : PackedScene = preload("res://Scenes/events/HouseEventInside.tscn")

func _on_control_mouse_entered() -> void:
	door.material = outlineMaterial

func _on_control_mouse_exited() -> void:
	door.material = null


func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			get_tree().change_scene_to_packed(house_inside)
