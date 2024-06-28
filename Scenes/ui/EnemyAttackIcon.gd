extends Control

@onready var sprite = $Node2D/Sprite
@onready var amountLabel = $Node2D/AmountLabel
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_data(attack_name,attack_amount):
	sprite.texture = load("res://Sprites/ui/enemyAttacks/"+attack_name+".png")
	amountLabel.text = str(attack_amount)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
