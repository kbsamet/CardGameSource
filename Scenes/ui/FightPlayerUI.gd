extends Control
class_name PlayerUI
@onready var healthBarRect = $HealthBar/HealthBarRect
@onready var healthBarLabel = $HealthBar/HealthLabel
@onready var apLabel = $ApBar/ApBarOutline/ApLabel
@onready var rpLabel = $RpBar/RpBarOutline/RpLabel
@onready var apBar = $ApBar
@onready var rpBar = $RpBar
@onready var endTurnButton = $Container/EndTurnButton
@onready var endTurnButtonLabel = $Container/EndTurnButton/EndTurnlabel
@onready var statusEffects = $StatusEffectsContainer
@onready var deckCountLabel = $Deck/DeckCountLabel
@onready var goldLabel = $GoldLabel
@onready var keyLabel = $KeyLabel
@onready var relicContainer = $RelicsContainer
signal end_turn_clicked

var health_bar_full_width

var action_button_texture = preload("res://Sprites/ui/end_action.png")
var reaction_button_texture = preload("res://Sprites/ui/end_reaction.png")
var disabled_material = preload("res://Shaders/gray_tint.tres")

var statusEffectIcon = preload("res://Scenes/ui/StatusEffectIcon.tscn")
var relicIcon = preload("res://Scenes/ui/RelicIcon.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar_full_width = healthBarRect.size.x
	db.player_status_effect_changed.connect(status_effect_changed)
	db.player_state_changed.connect(update_ui_values)
	db.turn_changed.connect(turn_changed)
	db.player.relics_changed.connect(relics_changed)
	update_ui_values()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_ui_values():
	if !is_inside_tree():
		return
	var tween = create_tween()
	if tween == null:
		return
	tween.tween_property(healthBarRect,"size:x",(float(db.player.health) / float(db.player.max_health)) * health_bar_full_width,0.1)
	
	goldLabel.text = ":"+str(db.player.gold)
	keyLabel.text = ":"+str(db.player.keys)
	apLabel.text = str(db.player.ap) + " / " + str(db.player.max_ap)
	rpLabel.text = str(db.player.rp) + " / " + str(db.player.max_rp)
	healthBarLabel.text =  str(db.player.health) + " / " + str(db.player.max_health)
	tween.tween_method(func(value): apBar.material.set_shader_parameter("cutoff", value),apBar.material.get_shader_parameter("cutoff"),float(db.player.ap) / float(db.player.max_ap),0.2)
	tween.tween_method(func(value): rpBar.material.set_shader_parameter("cutoff", value),rpBar.material.get_shader_parameter("cutoff"),float(db.player.rp) / float(db.player.max_rp),0.2)
	deckCountLabel.text = str(db.player.deck.size()) + " / " + str(db.player.deck_size )
	relics_changed()
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
			
func status_effect_changed():
	for n in statusEffects.get_children():
		statusEffects.remove_child(n)
		n.queue_free()
		
	var effects = db.player.status_effects
	for effect in effects.keys():
		if effects[effect] != 0:
			var icon = statusEffectIcon.instantiate()
			statusEffects.add_child(icon)
			icon.set_data(effect,effects[effect])

func relics_changed():
	for n in relicContainer.get_children():
		relicContainer.remove_child(n)
		n.queue_free()
	
	var relics = db.player.relics
	for relic in relics:
		var relic_icon = relicIcon.instantiate()
		relicContainer.add_child(relic_icon)
		relic_icon.set_data(relic)
