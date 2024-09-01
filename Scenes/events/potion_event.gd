extends Control

@onready var potion : Sprite2D = $Control/Potion
@onready var outlineMaterial : ShaderMaterial = preload("res://Shaders/outline.tres")
@onready var bg : Sprite2D = $Event
var potion_types : Array[String] = ["red","blue","green","orange"]
var potion_type : String

func _ready() -> void:
	potion_type = potion_types.pick_random()
	potion.texture = load("res://Sprites/ui/screens/events/potionEvent/potion_"+potion_type+".png")
func _on_control_mouse_entered() -> void:
	potion.material = outlineMaterial
	
func _on_control_mouse_exited() -> void:
	if is_instance_valid(potion):
		potion.material = null


func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_instance_valid(potion):
		if event.is_released():
			match potion_type:
				"red":
					db.player.heal_player(10)
				"blue":
					db.player.add_player_status_effect("give_rp",3)
				"orange":
					db.player.add_player_status_effect("give_ap",3)
				"green":
					db.player.damage_player(5)
			potion.queue_free()
			bg.texture = load("res://Sprites/ui/screens/events/potionEvent/potionBackground.png")
			
