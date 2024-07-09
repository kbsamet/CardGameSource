extends Control

@onready var sprite = $Node2D/Sprite
@onready var amountLabel = $Node2D/AmountLabel
@onready var descriptionLabel = $InfoBox/InfoLabel
@onready var infoBox = $InfoBox
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_data(attack_name:String, attack_amount : int):
	sprite.texture = load("res://Sprites/ui/enemyAttacks/"+attack_name+".png")
	amountLabel.text = str(attack_amount)
	var tooltip = db.enemy_tooltips[attack_name]
	tooltip = tooltip.replace("_", str(attack_amount))
	descriptionLabel.text = tooltip
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	infoBox.visible = true


func _on_mouse_exited():
	infoBox.visible = false
