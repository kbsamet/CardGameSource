extends Control
class_name PlayerUI

@onready var endTurnButton = $CanvasLayer/Container/EndTurnButton
@onready var endTurnButtonLabel = $CanvasLayer/Container/EndTurnButton/EndTurnlabel
@onready var deckCountLabel = $CanvasLayer/Deck/DeckCountLabel
@onready var discardPile = $CanvasLayer/DiscardPile
@onready var deck = $CanvasLayer/Deck
@onready var discardPileLabel = $CanvasLayer/DiscardPile/DiscardPileCountLabel

signal end_turn_clicked

var action_button_texture = preload("res://Sprites/ui/end_action.png")
var reaction_button_texture = preload("res://Sprites/ui/end_reaction.png")
var disabled_material = preload("res://Shaders/gray_tint.tres")

var boss_data : EnemyData = null
# Called when the node enters the scene tree for the first time.
func _ready():
	db.turn_changed.connect(turn_changed)
	db.player_state_changed.connect(update_ui_values)
	if boss_data != null:
		$CanvasLayer/BossControl.visible = true
	update_ui_values()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_ui_values():
	if !is_inside_tree():
		return
	deckCountLabel.text = str(db.player.deck.size()) + " / " + str(db.player.deck_size )
	discardPileLabel.text = str(db.player.discardPile.size()) + " / " + str(db.player.deck_size )
	

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
			
func _input(event):
	if event.is_action_pressed("ui_press_button"):
		end_turn_clicked.emit()
		db.clickPlayer.play()
		
func _on_button_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			end_turn_clicked.emit()

@onready var healthLabel = $CanvasLayer/BossControl/HealthBar/HealthLabel
@onready var staminaLabel = $CanvasLayer/BossControl/StaminaBar/StaminaLabel
@onready var healthBarRect = $CanvasLayer/BossControl/HealthBar/HealthBarRect
@onready var staminaBarRect = $CanvasLayer/BossControl/StaminaBar/StaminaBarRect
@onready var blockSprite = $CanvasLayer/BossControl/HealthBar/BlockIcon
@onready var blockAmountLabel = $CanvasLayer/BossControl/HealthBar/BlockIcon/Label
@onready var blockBarRect =	$CanvasLayer/BossControl/HealthBar/BlockBarRect
var health_bar_full_width = -1
var stamina_bar_full_width = -1

func set_boss_data(enemy_data: EnemyData):
	healthLabel.text = str(enemy_data.health) + "/" + str(enemy_data.max_health)
	staminaLabel.text = str(enemy_data.stamina) + "/" + str(enemy_data.max_stamina)
	if health_bar_full_width == -1:
		health_bar_full_width = healthBarRect.size.x
	if stamina_bar_full_width == -1:
		stamina_bar_full_width = staminaBarRect.size.x
	boss_data = enemy_data
	update_health_bar_ui()
	$CanvasLayer/BossControl.visible = true

func remove_boss_data():
	$CanvasLayer/BossControl.visible = false
func update_health_bar_ui():
	var tween =  create_tween()
	var max_health_bar_amount = float(boss_data.max_health)
	var block_amount = boss_data.get_status_effect("block")
	if block_amount != -1:
		blockSprite.visible = true
		blockAmountLabel.text = str(block_amount)
		var block_bar_width = (float(block_amount) / (max_health_bar_amount + float(block_amount))) * health_bar_full_width
		var missing_health_width = (float(max_health_bar_amount - boss_data.health) /max_health_bar_amount) * health_bar_full_width
		tween.tween_property(blockBarRect,"position:x",healthBarRect.position.x + health_bar_full_width - max(block_bar_width,missing_health_width),0.1)
		tween.tween_property(blockBarRect,"size:x",block_bar_width,0.1)
		#max_health_bar_amount += block_bar_width
		blockBarRect.visible= true
	else:
		blockSprite.visible = false
		blockBarRect.size.x = 0
		blockBarRect.visible = false
	tween.tween_property(healthBarRect,"size:x", (float(boss_data.health) / float(boss_data.max_health)) * float(health_bar_full_width),0.2)
	tween.tween_property(staminaBarRect,"size:x", (float(boss_data.stamina) / float(boss_data.max_stamina)) * float(stamina_bar_full_width),0.2)
	staminaLabel.text = str(boss_data.stamina) + "/" + str(boss_data.max_stamina)
	healthLabel.text = str(boss_data.health) + "/" + str(boss_data.max_health)
