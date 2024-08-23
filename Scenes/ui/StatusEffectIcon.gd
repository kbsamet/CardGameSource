extends Control
class_name StatusEffectIcon
@onready var sprite : Sprite2D = $Sprite
@onready var amountLabel : Label = $EffectAmountLabel
@onready var tooltip : TooltipNode = $Tooltip

var data : StatusEffectData

func set_data(new_data : StatusEffectData,tooltip_scale :Vector2 = Vector2(1,1)) -> void:
	data = new_data
	var effect : StatusEffectData = data
	if sprite == null:
		return
	sprite.texture = load("res://Sprites/ui/statusEffects/"+effect._name+".png")
	amountLabel.text = str(effect.amount)
	var tooltip_description : String = effect.tooltip
	tooltip_description = tooltip_description.replace("_", str(effect.amount))
	tooltip.set_data(tooltip_description,tooltip_scale)

func _on_mouse_entered() -> void:
	tooltip.visible = true


func _on_mouse_exited()-> void:
	tooltip.visible =false
