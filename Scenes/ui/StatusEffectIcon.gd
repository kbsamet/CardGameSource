extends Control

@onready var sprite = $Sprite
@onready var amountLabel = $EffectAmountLabel
@onready var InfoBox = $InfoBox
@onready var descriptionLabel = $InfoBox/InfoLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_data(effect_name: String ,effect_amount : int):
	sprite.texture = load("res://Sprites/ui/statusEffects/"+effect_name+".png")
	amountLabel.text = str(effect_amount)
	var tooltip = db.tooltips[effect_name]
	tooltip = tooltip.replace("_", str(effect_amount))
	descriptionLabel.text = tooltip
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	InfoBox.visible = true


func _on_mouse_exited():
	InfoBox.visible = false
