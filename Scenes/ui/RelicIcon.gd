extends Control

@onready var sprite = $Sprite
@onready var InfoBox = $InfoBox
@onready var descriptionLabel = $InfoBox/InfoLabel

var outline_material = preload("res://Shaders/outline.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_data(relic: RelicData):
	sprite.texture = load("res://Sprites/ui/relics/"+relic._name+".png")
	var tooltip = relic.description
	descriptionLabel.text = tooltip
	var scale_factor = Vector2(2,2) / get_global_transform().get_scale()
	var newSize = Vector2(InfoBox.size.x * scale_factor.x, InfoBox.size.y * scale_factor.y)
	InfoBox.size = newSize
	descriptionLabel.scale = scale_factor
	InfoBox.size.y = descriptionLabel.get_minimum_size().y + (80 if get_global_transform().get_scale() == Vector2(1,1) else 0)
	if is_off_screen():
		InfoBox.scale.x *= -1
		descriptionLabel.scale.x *= -1
		InfoBox.position = Vector2(-8,0)
		descriptionLabel.position = Vector2(106,8)
	
func is_off_screen() -> bool:
	# Get the viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	var global_scale = InfoBox.get_global_transform().get_scale()
	# Check if the panel is off the screen
	if InfoBox.global_position.x + (InfoBox.size.x * global_scale.x) > viewport_size.x:
		return true

	return false
func _process(delta):
	pass


func _on_mouse_entered():
	InfoBox.visible = true
	sprite.material = outline_material


func _on_mouse_exited():
	InfoBox.visible = false
	sprite.material = null
