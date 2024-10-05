extends Control
class_name  RewardCardScene
signal card_chosen(id :int)
var outlineShader : ShaderMaterial = preload("res://Shaders/outline.tres")
var tooltipScene : PackedScene = preload("res://Scenes/ui/Tooltip.tscn")
@onready var sprite : Sprite2D = $Card
@onready var manaLabel : Label = $ManaLabel
@onready var typeLabel : Label = $TypeLabel
@onready var nameLabel : Label = $NameLabel
@onready var descriptionLabel : RichTextLabel = $VBoxContainer2/DescriptionLabel
@onready var tooltipContainer : VBoxContainer = $VBoxContainer
var id : int
var card_data : CardData
var no_outline : bool = false
var clicked : bool = false

func set_data(data:CardData,_id : int,no_outline : bool=false) -> void:
	self.no_outline = no_outline
	id = _id
	card_data = data
	sprite.texture = load("res://Sprites/cards/"+data._name+".png")
	manaLabel.text = str(data.cost)
	typeLabel.text = "A" if data.type == db.CardType.Action else "R" if data.type == db.CardType.Reaction else "N"
	nameLabel.text = data._name
	descriptionLabel.text = "[center]" + data.description
	if data.is_damage_card():
		for effect in card_data.effects:
			if effect.effect == db.CardEffect.Damage:
				descriptionLabel.text = descriptionLabel.text.replace("/damage",str(effect.amount))
			elif effect.effect == db.CardEffect.DamageAll:
				descriptionLabel.text =descriptionLabel.text.replace("/damageAll",str(effect.amount))
			elif effect.effect == db.CardEffect.Riposte:
				descriptionLabel.text =descriptionLabel.text.replace("/riposte",str(effect.amount))
	init_info()


func _on_mouse_entered() -> void:
	if !no_outline:
		sprite.material = outlineShader
	show_info()


func _on_mouse_exited() -> void:
	if !no_outline:
		sprite.material = null
	remove_info()

func _on_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() and not clicked:
			db.clickPlayer.play()
			card_chosen.emit(id)
			clicked = true
	
func remove_info() -> void:
	for n in tooltipContainer.get_children():
		n.visible = false

func show_info() -> void:
	for n in tooltipContainer.get_children():
		n.visible = true
func init_info() -> void:
	for effect in card_data.effects:
		if effect.effect in db.card_tooltips:
			var tooltip : String = db.card_tooltips[effect.effect]
			tooltip = tooltip.replace("_",str(effect.amount))
			var new_tooltip : TooltipNode = tooltipScene.instantiate()
			tooltipContainer.add_child(new_tooltip)
			new_tooltip.set_data(tooltip)
