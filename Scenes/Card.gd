extends Node2D
class_name CardNode

var card_data : CardData
signal on_clicked_signal(id: int)
signal on_hold_signal(id: int)
var id: int
var selected: bool = false
var disabled: bool = false
var hovered: bool = false
var dragged: bool = false
var original_text: String = ""
@onready var manaLabel: Label = $Control/ManaLabel
@onready var typeLabel: Label = $Control/TypeLabel
@onready var nameLabel: Label = $Control/NameLabel
@onready var descriptionLabel : RichTextLabel= $Control/DescriptionContainer/DescriptionLabel 
@onready var sprite: Sprite2D = $Sprite
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var control : Control = $Control
@onready var tooltipContainer : VBoxContainer = $Control2/VBoxContainer
@onready var hoverPlayer : AudioStreamPlayer = $hoverPlayer

@onready var outlineShader : ShaderMaterial = preload("res://Shaders/outline.tres")
@onready var outlineBlueShader : ShaderMaterial= preload("res://Shaders/outline_blue.tres")
@onready var outlineRedShader: ShaderMaterial = preload("res://Shaders/outline_red.tres")
@onready var disabledShader: ShaderMaterial = preload("res://Shaders/gray_tint.tres")
@onready var tooltipNode : PackedScene= preload("res://Scenes/ui/Tooltip.tscn")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db.turn_changed.connect(_turn_changed)
	db.player_state_changed.connect(_player_state_changed)
	db.player_status_effect_changed.connect(_player_status_effect_changed)
	_turn_changed(db.current_turn)
	manaLabel.text = str(card_data.cost)
	typeLabel.text = "A" if (card_data.type == db.CardType.Action) else "R" if card_data.type == db.CardType.Reaction else "N"
	nameLabel.text = card_data._name
	descriptionLabel.text = "[center]" + card_data.description
	add_description_colors()
	original_text = descriptionLabel.text
	if card_data.is_damage_card():
		add_damage_color()
	sprite.texture = load("res://Sprites/cards/"+card_data._name+".png")
	if len(nameLabel.text) > 16:
		nameLabel.scale = Vector2(0.7,0.7)
	init_info()

func add_description_colors()-> void:
	var keyword_loc : int = -1
	for keyword : String in db.card_keywords:
		keyword_loc = descriptionLabel.text.to_lower().find(keyword)
		if keyword_loc != -1:
			descriptionLabel.text = descriptionLabel.text.insert(keyword_loc+len(keyword),"[/color]").insert(keyword_loc,"[color=e8c65b]")
	
func add_damage_color() -> void:
	descriptionLabel.text = original_text
		
	if not "empowered" in db.player.status_effects:
		for effect in card_data.effects:
			if effect.effect == db.CardEffect.Damage:
				descriptionLabel.text = descriptionLabel.text.replace("/damage",str(effect.amount))
			elif effect.effect == db.CardEffect.DamageAll:
				descriptionLabel.text =descriptionLabel.text.replace("/damageAll",str(effect.amount))
			elif effect.effect == db.CardEffect.Riposte:
				descriptionLabel.text =descriptionLabel.text.replace("/riposte",str(effect.amount))
		add_description_colors()
		return
	var new_damage : String = ""
	for effect in card_data.effects:
		if effect.effect == db.CardEffect.Damage:
			new_damage = str(effect.amount + db.player.status_effects["empowered"].amount)
			descriptionLabel.text = descriptionLabel.text.replace("/damage","[color=74ab74]"+ new_damage + "[/color]")
		elif effect.effect == db.CardEffect.DamageAll:
			new_damage = str(effect.amount + db.player.status_effects["empowered"].amount)
			descriptionLabel.text = descriptionLabel.text.replace("/damageAll","[color=74ab74]"+ new_damage + "[/color]")
		elif effect.effect == db.CardEffect.Riposte:
			new_damage = str(effect.amount + db.player.status_effects["empowered"].amount)
			descriptionLabel.text = descriptionLabel.text.replace("/riposte","[color=74ab74]"+ new_damage + "[/color]")
			
		add_description_colors()
func _player_status_effect_changed()-> void:
	if card_data.is_damage_card():
		add_damage_color()
		
func _player_state_changed()-> void:
	if card_data.type == db.CardType.Neutral:
		if (db.current_turn == db.Turn.PlayerAction and db.player.ap >= card_data.cost) or \
		 (db.current_turn == db.Turn.PlayerReaction and db.player.rp >= card_data.cost):
			disabled = false
			sprite.material = null
		elif db.current_turn == db.Turn.PlayerAction or db.Turn.PlayerReaction:
			sprite.material = disabledShader
			disabled = true
	elif (card_data.type == db.CardType.Action && db.player.ap < card_data.cost) ||\
		(card_data.type == db.CardType.Reaction && db.player.rp < card_data.cost):
		sprite.material = disabledShader
		disabled = true
	elif (card_data.type == db.CardType.Action && db.current_turn == db.Turn.PlayerAction) ||\
			(card_data.type == db.CardType.Reaction && db.current_turn == db.Turn.PlayerReaction):
		sprite.material = null
		disabled = false
func _turn_changed(new_turn : db.Turn)-> void:
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
func _process(delta : float) -> void:
	if dragged and (!card_data.targeted or "blind" in db.player.status_effects):
		global_position = get_global_mouse_position() #+ (control.size / 2)
		if position.y < -300:
			if card_data.type == db.CardType.Action:
				sprite.material = outlineRedShader
			else:
				sprite.material = outlineBlueShader
		else:
			sprite.material = outlineShader
	

func _on_hover()-> void:
	if selected or dragged:
		remove_info()
		return
	animationPlayer.stop()
	animationPlayer.play("hover")
	#sprite.material = outlineShader
	show_info()
	hovered = true
	z_index = 10

func _on_hover_over()-> void:
	remove_info()
	if selected or dragged:
		return
	if !selected:
		animationPlayer.stop()
		animationPlayer.play("restore")
		#sprite.material = null
		hovered = false
		
		z_index = 8

func set_selected(new_selected : bool)-> void:
	remove_info()
	if new_selected:
		selected = new_selected
	else:
		selected = new_selected
		animationPlayer.stop()
		animationPlayer.play("restore")
		sprite.material = null
		z_index = 8
		
func _on_input(event : InputEvent)-> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			on_hold_signal.emit(id)
			if !disabled:
				dragged = true
				hoverPlayer.play()
		if event.is_released():
			on_hold_signal.emit(-1)
			dragged = false
			if Rect2(control.global_position,control.size).has_point(get_global_mouse_position()):
				on_clicked_signal.emit(id)

func remove_info()-> void:
	for n in tooltipContainer.get_children():
		n.visible = false

func show_info()-> void:
	for n in tooltipContainer.get_children():
		n.visible = true
func init_info()-> void:
	for effect in card_data.effects:
		if effect.effect in db.card_tooltips:
			var tooltip : String = db.card_tooltips[effect.effect]
			tooltip = tooltip.replace("_",str(effect.amount))
			var new_tooltip : TooltipNode = tooltipNode.instantiate()
			tooltipContainer.add_child(new_tooltip)
			new_tooltip.set_data(tooltip)
