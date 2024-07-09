extends Control

@onready var sprite = $Sprite
@onready var amountLabel = $EffectAmountLabel
@onready var InfoBox = $InfoBox
@onready var descriptionLabel = $InfoBox/InfoLabel

var data : StatusEffectData
# Called when the node enters the scene tree for the first time.
func _ready():
	load_data()

func set_data(effect : StatusEffectData):
	data = effect

func load_data():
	var effect = data
	sprite.texture = load("res://Sprites/ui/statusEffects/"+effect._name+".png")
	amountLabel.text = str(effect.amount)
	var tooltip = effect.tooltip
	tooltip = tooltip.replace("_", str(effect.amount))
	descriptionLabel.text = tooltip
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	InfoBox.visible = true


func _on_mouse_exited():
	InfoBox.visible = false
