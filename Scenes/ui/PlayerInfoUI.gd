extends Control
var statusEffectIcon = preload("res://Scenes/ui/StatusEffectIcon.tscn")
var relicIcon = preload("res://Scenes/ui/RelicIcon.tscn")

@onready var blockIcon = $HealthBar/BlockIcon
@onready var blockAmountLabel = $HealthBar/BlockIcon/Label
@onready var healthBarSprite = $HealthBar
@onready var healthBarRect = $HealthBar/HealthBarRect
@onready var blockBarRect = $HealthBar/BlockBarRect
@onready var healthBarLabel = $HealthBar/HealthLabel
@onready var apLabel = $ApBar/ApBarOutline/ApLabel
@onready var rpLabel = $RpBar/RpBarOutline/RpLabel
@onready var apBar = $ApBar
@onready var rpBar = $RpBar
@onready var statusEffects = $StatusEffectsContainer
@onready var goldLabel = $GoldLabel
@onready var keyLabel = $KeyLabel
@onready var relicContainer = $RelicsContainer

var health_bar_full_width
# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar_full_width = healthBarRect.size.x
	db.player_status_effect_changed.connect(status_effect_changed)
	db.player_state_changed.connect(update_ui_values)
	db.player.relics_changed.connect(relics_changed)
	update_ui_values()
	status_effect_changed()

func relics_changed():
	for n in relicContainer.get_children():
		relicContainer.remove_child(n)
		n.queue_free()
	
	var relics = db.player.relics
	for relic in relics:
		var relic_icon = relicIcon.instantiate()
		relicContainer.add_child(relic_icon)
		relic_icon.set_data(relic)


func update_ui_values():
	if !is_inside_tree():
		return
	var tween = create_tween().set_parallel()
	if tween == null:
		return
	var max_health_bar_amount = float(db.player.max_health)
	var block_amount = 0
	if "block" in db.player.status_effects and db.player.status_effects["block"].amount != 0:
		block_amount = db.player.status_effects["block"].amount
		blockIcon.visible = true
		blockAmountLabel.text = str(block_amount)
		var block_bar_width = (float(block_amount) / float(db.player.max_health + block_amount )) * health_bar_full_width
		var missing_health_width = (float(max_health_bar_amount - db.player.health) /max_health_bar_amount) * health_bar_full_width
		tween.tween_property(blockBarRect,"position:x",healthBarRect.position.x + health_bar_full_width - max(block_bar_width,missing_health_width),0.1)
		tween.tween_property(blockBarRect,"size:x",block_bar_width,0.1)
		#max_health_bar_amount += block_bar_width
		blockBarRect.visible= true
	else:
		blockIcon.visible = false
		blockBarRect.size.x = 0
		blockBarRect.visible = false
	tween.tween_property(healthBarRect,"size:x",(float(db.player.health) /max_health_bar_amount) * health_bar_full_width,0.1)
	goldLabel.text = ":"+str(db.player.gold)
	keyLabel.text = ":"+str(db.player.keys)
	apLabel.text = str(db.player.ap) + " / " + str(db.player.max_ap)
	rpLabel.text = str(db.player.rp) + " / " + str(db.player.max_rp)

	healthBarLabel.text = str(db.player.health ) + " / " + str(db.player.max_health)
	tween.tween_method(func(value): apBar.material.set_shader_parameter("cutoff", value),apBar.material.get_shader_parameter("cutoff"),float(db.player.ap) / float(db.player.max_ap),0.2)
	tween.tween_method(func(value): rpBar.material.set_shader_parameter("cutoff", value),rpBar.material.get_shader_parameter("cutoff"),float(db.player.rp) / float(db.player.max_rp),0.2)
	#deckCountLabel.text = str(db.player.deck.size()) + " / " + str(db.player.deck_size )
	#discardPileLabel.text = str(db.player.discardPile.size()) + " / " + str(db.player.deck_size )
	relics_changed()
	
func status_effect_changed():
	for n in statusEffects.get_children():
		statusEffects.remove_child(n)
		n.queue_free()
	
	for effect in db.player.status_effects.values():
		if effect.amount != 0 && !effect.hidden:
			var icon = statusEffectIcon.instantiate()
			icon.set_data(effect)
			statusEffects.add_child(icon)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
