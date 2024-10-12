extends Control
class_name PlayerUI

@onready var endTurnButton : Sprite2D= $CanvasLayer/Container/EndTurnButton
@onready var endTurnButtonLabel: Label = $CanvasLayer/Container/EndTurnButton/EndTurnlabel
@onready var deckCountLabel : Label = $CanvasLayer/Control/Deck/DeckCountLabel
@onready var discardPile : Sprite2D = $CanvasLayer/Control2/DiscardPile
@onready var deck : Sprite2D = $CanvasLayer/Control/Deck
@onready var discardPileLabel : Label = $CanvasLayer/Control2/DiscardPile/DiscardPileCountLabel
@onready var cardPileScreen : CardPileScreen = $CanvasLayer/CardPileScreen
@onready var abilityIcon : Sprite2D = $CanvasLayer/Control3/AbilityIcon
@onready var abilityAnimation : AnimatedSprite2D = $CanvasLayer/AbilityAnimationSprite

signal end_turn_clicked

var outline_material : ShaderMaterial= preload("res://Shaders/outline.tres")
var action_button_texture : CompressedTexture2D = preload("res://Sprites/ui/end_action.png")
var reaction_button_texture: CompressedTexture2D  = preload("res://Sprites/ui/end_reaction.png")
var disabled_material: ShaderMaterial = preload("res://Shaders/gray_tint.tres")

var boss_data : EnemyData = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	abilityAnimation.animation = db.player.ability._name
	abilityIcon.texture = load("res://Sprites/abilities/"+db.player.ability._name+".png")
	$CanvasLayer/Control3/Tooltip.set_data(db.player.ability.get_tooltip())
	db.turn_changed.connect(turn_changed)
	db.player_state_changed.connect(update_ui_values)
	if boss_data != null:
		$CanvasLayer/BossControl.visible = true
	update_ui_values()
	
	
func update_ui_values()-> void:
	if !is_inside_tree():
		return
	if "silence" in db.player.status_effects or (db.player.ability.cost > db.player.mana and "energized" not in db.player.status_effects):
		abilityIcon.material = disabled_material
	else:
		abilityIcon.material = null
	deckCountLabel.text = str(db.player.deck.size()) + " / " + str(db.player.deck_size )
	discardPileLabel.text = str(db.player.discardPile.size()) + " / " + str(db.player.deck_size )
	$CanvasLayer/Control3/Tooltip.set_data(db.player.ability.get_tooltip())
	

func turn_changed(new_turn : db.Turn)-> void:
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
			
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_press_button"):
		end_turn_clicked.emit()
		db.clickPlayer.play()
		
func _on_button_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			end_turn_clicked.emit()

@onready var healthLabel : Label = $CanvasLayer/BossControl/HealthBar/HealthLabel
@onready var staminaLabel: Label = $CanvasLayer/BossControl/StaminaBar/StaminaLabel
@onready var healthBarRect : Panel= $CanvasLayer/BossControl/HealthBar/HealthBarRect
@onready var staminaBarRect : Panel = $CanvasLayer/BossControl/StaminaBar/StaminaBarRect
@onready var blockSprite : Sprite2D = $CanvasLayer/BossControl/HealthBar/BlockIcon
@onready var blockAmountLabel : Label = $CanvasLayer/BossControl/HealthBar/BlockIcon/Label
@onready var blockBarRect : Panel =	$CanvasLayer/BossControl/HealthBar/BlockBarRect
@onready var bossname : Label = $CanvasLayer/BossControl/Label
@onready var bossSpeakLabel : Label = $CanvasLayer/BossControl/BossTalkLabel
var health_bar_full_width : float = -1
var stamina_bar_full_width : float = -1

func set_boss_data(enemy_data: EnemyData) -> void:
	healthLabel.text = str(enemy_data.health) + "/" + str(enemy_data.max_health)
	staminaLabel.text = str(enemy_data.stamina) + "/" + str(enemy_data.max_stamina)
	if health_bar_full_width == -1:
		health_bar_full_width = healthBarRect.size.x
	if stamina_bar_full_width == -1:
		stamina_bar_full_width = staminaBarRect.size.x
	boss_data = enemy_data
	bossname.text = enemy_data._name
	update_health_bar_ui()
	$CanvasLayer/BossControl.visible = true

func remove_boss_data() -> void:
	$CanvasLayer/BossControl.visible = false
func update_health_bar_ui() -> void:
	var tween : Tween =  create_tween()
	var max_health_bar_amount : float = float(boss_data.max_health)
	var block_amount : int = boss_data.get_status_effect("block")
	if block_amount != -1:
		blockSprite.visible = true
		blockAmountLabel.text = str(block_amount)
		var block_bar_width : float= (float(block_amount) / (max_health_bar_amount + float(block_amount))) * health_bar_full_width
		var missing_health_width : float = (float(max_health_bar_amount - boss_data.health) /max_health_bar_amount) * health_bar_full_width
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

func play_ability_animation() -> void:
	abilityAnimation.visible = true
	abilityAnimation.play()
	abilityAnimation.animation_looped.connect(ability_animation_finished)

func bossTalk(say : String) -> Signal:
	bossSpeakLabel.modulate.a = 0
	bossSpeakLabel.visible = true
	bossSpeakLabel.text = say
	var tween :Tween = create_tween()
	tween.tween_property(bossSpeakLabel,"modulate:a",1,0.5)
	tween.tween_property(bossSpeakLabel,"modulate:a",1,2)
	tween.tween_property(bossSpeakLabel,"modulate:a",0,0.5)
	tween.tween_callback(func() -> void : bossSpeakLabel.visible = false)
	return tween.finished

func ability_animation_finished() -> void:
	abilityAnimation.visible = false
	abilityAnimation.stop()
func _on_deck_mouse_entered() -> void:
	deck.material = outline_material
func _on_discard_pile_mouse_entered()-> void:
	discardPile.material = outline_material
func _on_deck_mouse_exited()-> void:
	deck.material = null
func _on_discard_pile_mouse_exited()-> void:
	discardPile.material = null
func _on_deck_gui_input(event : InputEvent)-> void:
	if event is InputEventMouseButton:
		if event.is_released():
			if cardPileScreen.visible:
				cardPileScreen.visible = false
				return
			cardPileScreen.set_data(db.player.deck)
			cardPileScreen.visible = true

func _on_discard_pile_gui_input(event : InputEvent)-> void:
	if event is InputEventMouseButton:
		if event.is_released():
			if cardPileScreen.visible:
				cardPileScreen.visible = false
				return
			cardPileScreen.set_data(db.player.discardPile)
			cardPileScreen.visible = true


func _on_ability_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			var ability_used : bool = db.player.use_ability()
			if ability_used:
				play_ability_animation()
