extends Control

@onready var sprite = $Sprite
@onready var tooltip : TooltipNode = $Tooltip
var outline_material = preload("res://Shaders/outline.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	tooltip.set_data("deneme 123")
	pass # Replace with function body.

func _on_mouse_entered():
	sprite.material = outline_material
	tooltip.visible = true


func _on_mouse_exited():
	sprite.material = null
	tooltip.visible = false
