extends Node2D


var card_data : db.Card
signal on_clicked_signal(id)
var id: int
var selected = false
@onready var manaLabel = $Control/ManaLabel
@onready var typeLabel = $Control/TypeLabel
@onready var nameLabel = $Control/NameLabel
@onready var descriptionLabel = $Control/DescriptionLabel
@onready var sprite = $Sprite
@onready var animationPlayer = $AnimationPlayer

@onready var outlineShader = preload("res://Shaders/outline.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	manaLabel.text = str(card_data.cost)
	typeLabel.text = "A" if (card_data.type == db.CardType.Action) else "R"
	nameLabel.text = card_data._name
	descriptionLabel.text = card_data.description
	sprite.texture = load("res://Sprites/cards/"+card_data._name+".png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_hover():
	animationPlayer.stop()
	animationPlayer.play("hover")
	sprite.material = outlineShader
	z_index = 10

func _on_hover_over():
	if !selected:
		animationPlayer.stop()
		animationPlayer.play("restore")
		sprite.material = null
		z_index = 5

func set_selected(new_selected):
	if new_selected:
		selected = new_selected
	else:
		selected = new_selected
		animationPlayer.stop()
		animationPlayer.play("restore")
		sprite.material = null
		z_index = 5
		
func _on_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.is_released():
			on_clicked_signal.emit(id)
