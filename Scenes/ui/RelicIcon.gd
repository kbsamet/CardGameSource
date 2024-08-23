extends Control
class_name  RelicIcon
@onready var sprite : Sprite2D = $Sprite
@onready var tooltip : TooltipNode = $Tooltip

var outline_material : ShaderMaterial = preload("res://Shaders/outline.tres")
func set_data(relic: RelicData) -> void:
	sprite.texture = load("res://Sprites/ui/relics/"+relic._name+".png")
	tooltip.set_data(relic.description)
	if global_position.x + get_global_rect().size.x + tooltip.get_global_rect().size.x > get_viewport_rect().size.x:
		tooltip.scale.x = -1
		$Tooltip/InfoBox/InfoLabel.scale.x = -1
		$Tooltip/InfoBox/InfoLabel.position.x = 215
		tooltip.position.x = -10
	if sprite.texture.get_width() == 64:
		sprite.scale = Vector2(1,1)

func _on_mouse_entered() -> void:
	tooltip.visible = true
	sprite.material = outline_material

func _on_mouse_exited() -> void:
	tooltip.visible = false
	sprite.material = null
