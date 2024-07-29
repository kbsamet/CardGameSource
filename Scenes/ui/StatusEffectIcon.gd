extends Control

@onready var sprite = $Sprite
@onready var amountLabel = $EffectAmountLabel
@onready var tooltip = $Tooltip

var data : StatusEffectData

func set_data(new_data : StatusEffectData,tooltip_scale :Vector2 = Vector2(1,1)):
	data = new_data
	var effect = data
	if sprite == null:
		return
	sprite.texture = load("res://Sprites/ui/statusEffects/"+effect._name+".png")
	amountLabel.text = str(effect.amount)
	var tooltip_description = effect.tooltip
	tooltip_description = tooltip_description.replace("_", str(effect.amount))
	tooltip.set_data(tooltip_description,tooltip_scale)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	tooltip.visible = true


func _on_mouse_exited():
	tooltip.visible =false
