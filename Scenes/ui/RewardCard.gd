extends Control
class_name  RewardCardScene
signal card_chosen(id)
var outlineShader = preload("res://Shaders/outline.tres")
var tooltipScene = preload("res://Scenes/ui/Tooltip.tscn")
@onready var sprite = $Card
@onready var manaLabel = $ManaLabel
@onready var typeLabel = $TypeLabel
@onready var nameLabel = $NameLabel
@onready var descriptionLabel = $DescriptionLabel
@onready var tooltipContainer = $VBoxContainer
var id : int
var card_data : CardData
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_data(data:CardData,_id : int):
	id = _id
	card_data = data
	sprite.texture = load("res://Sprites/cards/"+data._name+".png")
	manaLabel.text = str(data.cost)
	typeLabel.text = "A" if data.type == db.CardType.Action else "R"
	nameLabel.text = data._name
	descriptionLabel.text = data.description
	init_info()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	sprite.material = outlineShader
	show_info()


func _on_mouse_exited():
	sprite.material = null
	remove_info()

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			card_chosen.emit(id)
	
func remove_info():
	for n in tooltipContainer.get_children():
		n.visible = false

func show_info():
	for n in tooltipContainer.get_children():
		n.visible = true
func init_info():
	for effect in card_data.effects:
		if effect.effect in db.card_tooltips:
			var tooltip = db.card_tooltips[effect.effect] as String
			tooltip = tooltip.replace("_",str(effect.amount))
			var new_tooltip = tooltipScene.instantiate()
			tooltipContainer.add_child(new_tooltip)
			new_tooltip.set_data(tooltip)
