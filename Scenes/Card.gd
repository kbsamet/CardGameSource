extends Node2D
class_name CardNode

var card_data : CardData
signal on_clicked_signal(id)
signal on_hold_signal(id)
var id: int
var selected = false
var disabled = false
var hovered = false
var dragged = false
@onready var manaLabel = $Control/ManaLabel
@onready var typeLabel = $Control/TypeLabel
@onready var nameLabel = $Control/NameLabel
@onready var descriptionLabel = $Control/DescriptionLabel
@onready var sprite = $Sprite
@onready var animationPlayer = $AnimationPlayer
@onready var control = $Control
@onready var tooltipContainer = $Control/VBoxContainer

@onready var outlineShader = preload("res://Shaders/outline.tres")
@onready var outlineBlueShader = preload("res://Shaders/outline_blue.tres")
@onready var outlineRedShader = preload("res://Shaders/outline_red.tres")
@onready var disabledShader = preload("res://Shaders/gray_tint.tres")
@onready var tooltipNode = preload("res://Scenes/ui/Tooltip.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	db.turn_changed.connect(_turn_changed)
	db.player_state_changed.connect(_player_state_changed)
	_turn_changed(db.current_turn)
	manaLabel.text = str(card_data.cost)
	typeLabel.text = "A" if (card_data.type == db.CardType.Action) else "R"
	nameLabel.text = card_data._name
	descriptionLabel.text = card_data.description
	sprite.texture = load("res://Sprites/cards/"+card_data._name+".png")
	init_info()

func _player_state_changed():
	if (card_data.type == db.CardType.Action && db.player.ap < card_data.cost) ||\
		(card_data.type == db.CardType.Reaction && db.player.rp < card_data.cost):
		sprite.material = disabledShader
		disabled = true
func _turn_changed(new_turn):
	if hovered:
		_on_hover_over()
	if (new_turn == db.Turn.PlayerAction && card_data.type == db.CardType.Reaction) || \
	 (new_turn == db.Turn.PlayerReaction && card_data.type == db.CardType.Action) || \
	 new_turn == db.Turn.EnemyAction || new_turn == db.Turn.EnemyReaction || \
		(card_data.type == db.CardType.Action && db.player.ap < card_data.cost) ||\
		(card_data.type == db.CardType.Reaction && db.player.rp < card_data.cost):
		sprite.material = disabledShader
		disabled = true
		return
	disabled = false
	sprite.material = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dragged and (!card_data.targeted or "blind" in db.player.status_effects):
		global_position = get_global_mouse_position() #+ (control.size / 2)
		if position.y < -300:
			if card_data.type == db.CardType.Action:
				sprite.material = outlineRedShader
			else:
				sprite.material = outlineBlueShader
		else:
			sprite.material = outlineShader
	

func _on_hover():
	if disabled or selected or dragged:
		remove_info()
		return
	animationPlayer.stop()
	animationPlayer.play("hover")
	sprite.material = outlineShader
	show_info()
	hovered = true
	z_index = 10

func _on_hover_over():
	remove_info()
	if disabled or selected or dragged:
		return
	if !selected:
		animationPlayer.stop()
		animationPlayer.play("restore")
		sprite.material = null
		hovered = false
		
		z_index = 8

func set_selected(new_selected):
	remove_info()
	if new_selected:
		selected = new_selected
	else:
		selected = new_selected
		animationPlayer.stop()
		animationPlayer.play("restore")
		sprite.material = null
		z_index = 8
		
func _on_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.is_pressed():
			on_hold_signal.emit(id)
			if !disabled:
				dragged = true
		if event.is_released():
			on_hold_signal.emit(-1)
			dragged = false
			if Rect2(control.global_position,control.size).has_point(get_global_mouse_position()):
				on_clicked_signal.emit(id)

func remove_info():
	for n in tooltipContainer.get_children():
		n.visible = false

func show_info():
	for n in tooltipContainer.get_children():
		n.visible = true
func init_info():
	for effect in card_data.effects.keys():
		if effect in db.card_tooltips:
			var tooltip = db.card_tooltips[effect] as String
			tooltip = tooltip.replace("_",str(card_data.effects[effect]))
			var new_tooltip = tooltipNode.instantiate()
			tooltipContainer.add_child(new_tooltip)
			new_tooltip.set_data(tooltip)
