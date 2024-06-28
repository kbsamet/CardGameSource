extends Control

@onready var healthBarRect = $HealthBar/HealthBarRect
@onready var healthBarLabel = $HealthBar/HealthLabel
@onready var apLabel = $ApBar/ApBarOutline/ApLabel
@onready var rpLabel = $RpBar/RpBarOutline/RpLabel
@onready var apBar = $ApBar
@onready var rpBar = $RpBar
@onready var endTurnButton = $Container/EndTurnButton
@onready var endTurnButtonLabel = $Container/EndTurnButton/EndTurnlabel

signal end_turn_clicked

var health_bar_full_width

var action_button_texture = preload("res://Sprites/ui/end_action.png")
var reaction_button_texture = preload("res://Sprites/ui/end_reaction.png")
var disabled_material = preload("res://Shaders/gray_tint.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	db.player_state_changed.connect(update_ui_values)
	db.turn_changed.connect(turn_changed)
	update_ui_values()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_ui_values():
	health_bar_full_width = healthBarRect.size.x
	healthBarRect.size.x = (float(db.Player.health) / float(db.Player.maxHealth)) * health_bar_full_width
	apLabel.text = str(db.Player.ap) + " / " + str(db.Player.maxAp)
	rpLabel.text = str(db.Player.rp) + " / " + str(db.Player.maxRp)
	healthBarLabel.text =  str(db.Player.health) + " / " + str(db.Player.maxHealth)
	apBar.material.set_shader_parameter("cutoff",float(db.Player.ap) / float(db.Player.maxAp))
	rpBar.material.set_shader_parameter("cutoff",float(db.Player.rp) / float(db.Player.maxRp))

func turn_changed(new_turn):
	match new_turn:
		db.Turn.PlayerAction:
			endTurnButton.texture = action_button_texture
			endTurnButtonLabel.text = "End Action"
			endTurnButton.material = null
		db.Turn.PlayerReaction:
			endTurnButton.texture = reaction_button_texture
			endTurnButtonLabel.text = "End Reaction"
			endTurnButton.material = null
		_:
			endTurnButton.texture = action_button_texture
			endTurnButton.material = disabled_material
func _on_button_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			end_turn_clicked.emit()
