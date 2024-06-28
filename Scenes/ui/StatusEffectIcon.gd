extends Node2D

@onready var sprite = $Sprite
@onready var amountLabel = $EffectAmountLabel
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_data(effect_name,effect_amount):
	sprite.texture = load("res://Sprites/ui/statusEffects/"+effect_name+".png")
	amountLabel.text = str(effect_amount)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
