extends Node2D
class_name EnemyNode
var enemy_data : EnemyData
var is_card_selected = false
var id : int
var hit_animation_playing = false
signal on_clicked_signal(id)
signal attack_rise_done(id)
signal attack_end_done(id)
signal enemy_dead(id)
signal enemy_hovered(id)
signal enemy_hovered_end(id)
@onready var sprite = $Sprite
@onready var blockSprite = $Control/HealthBar/BlockIcon
@onready var blockAmountLabel = $Control/HealthBar/BlockIcon/Label
@onready var healthBarSprite = $Control/HealthBar
@onready var healthBarRect = $Control/HealthBar/HealthBarRect
@onready var healthLabel = $Control/HealthBar/HealthLabel
@onready var blockBarRect = $Control/HealthBar/BlockBarRect
@onready var staminaBarRect = $Control/StaminaBar/StaminaBarRect
@onready var staminaLabel = $Control/StaminaBar/StaminaLabel
@onready var animationPlayer = $AnimationPlayer
@onready var statusEffectContainer = $Control/StatusEffectContainer
@onready var hitShader = preload("res://Shaders/hit_shader.tres").duplicate()
@onready var outlineShader = preload("res://Shaders/outline_red.tres")
@onready var attackIcon = preload("res://Scenes/ui/EnemyAttackIcon.tscn")
@onready var statusEffectIcon = preload("res://Scenes/ui/StatusEffectIcon.tscn")
@onready var infoPopup = $Control/InfoPopup
@onready var infoBox = $Control/InfoBox
@onready var hitAmountLabel = $Control/HitAmount
@onready var blockHitAmountLabel = $Control/BlockAmount
@onready var hitParticles = $HitParticles

var particle_color_red = Color("ca5954")
var particle_color_blue = Color("5c699f")

var stamina_bar_full_width
var health_bar_full_width
var selected_attack = null
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = load("res://Sprites/enemies/"+enemy_data._name+".png")
	healthLabel.text = str(enemy_data.health) + "/" + str(enemy_data.max_health)
	staminaLabel.text = str(enemy_data.stamina) + "/" + str(enemy_data.max_stamina)
	health_bar_full_width = healthBarRect.size.x
	stamina_bar_full_width = staminaBarRect.size.x
	set_status_effect_info()
	update_health_bar_ui()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_stamina(amount:int) -> void:
	var tween =  create_tween()
	enemy_data.stamina += amount
	tween.tween_property(staminaBarRect,"size:x", (float(enemy_data.stamina) / float(enemy_data.max_stamina)) * float(stamina_bar_full_width),0.2)
	staminaLabel.text = str(enemy_data.stamina) + "/" + str(enemy_data.max_stamina)
	if enemy_data.stamina == 0:
		add_status_effect("dazed",1)


func update_health_bar_ui():
	var tween =  create_tween()
	var max_health_bar_amount = float(enemy_data.max_health)
	if "block" in enemy_data.status_effects and enemy_data.status_effects["block"].amount != 0:
		var block_amount = enemy_data.status_effects["block"].amount
		blockSprite.visible = true
		blockAmountLabel.text = str(block_amount)
		var block_bar_width = (float(block_amount) / (max_health_bar_amount + float(block_amount))) * health_bar_full_width
		var missing_health_width = (float(max_health_bar_amount - enemy_data.health) /max_health_bar_amount) * health_bar_full_width
		tween.tween_property(blockBarRect,"position:x",healthBarRect.position.x + health_bar_full_width - max(block_bar_width,missing_health_width),0.1)
		tween.tween_property(blockBarRect,"size:x",block_bar_width,0.1)
		#max_health_bar_amount += block_bar_width
		blockBarRect.visible= true
	else:
		blockSprite.visible = false
		blockBarRect.size.x = 0
		blockBarRect.visible = false
	tween.tween_property(healthBarRect,"size:x", (float(enemy_data.health) / float(enemy_data.max_health)) * float(health_bar_full_width),0.2)
	healthLabel.text = str(enemy_data.health) + "/" + str(enemy_data.max_health)


func damage(amount):
	if !is_inside_tree():
		return
	var tween = create_tween()
	if "block" in enemy_data.status_effects:
		var block_amount = enemy_data.status_effects["block"].amount
		if block_amount > amount:
			blockHitAmountLabel.text = str(amount)
			animationPlayer.play("hit_block")
			add_status_effect("block", -amount)
			update_health_bar_ui()
			return
		else:
			blockHitAmountLabel.text = str(block_amount)
			animationPlayer.play("hit_block")
			add_status_effect("block", -block_amount)
			amount -= block_amount
		blockHitAmountLabel.visible = true
		hitParticles.color = particle_color_blue
		hitParticles.emitting = true
		
	hitAmountLabel.text = str(amount)
	if amount > 0:
		animationPlayer.queue("hit")
		hitParticles.color = particle_color_red
		hitParticles.emitting = true


	enemy_data.health -= amount
	if !hit_animation_playing:
		hit_animation_playing = true
		sprite.material = hitShader
		tween.tween_method(func(value): sprite.material.set_shader_parameter("time", value),0.0,1.0,0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(func(): hit_animation_playing = false)
	update_health_bar_ui()
	if enemy_data.health <= 0:
		enemy_dead.emit(id)

	
func _on_hover():
	enemy_hovered.emit(id)
	if is_card_selected:
		sprite.material = outlineShader


func _on_hover_end() -> void:
	if !hit_animation_playing:
		sprite.material = null
	enemy_hovered_end.emit(id)

func get_attack() -> Dictionary:
	var dazed = get_status_effect("dazed")
	var dazed_amount = null if dazed == null else dazed.amount
	if dazed_amount != null:
		if dazed_amount == 1:
			add_status_effect("dazed",-1)
			if enemy_data.stamina == 0:
				change_stamina(enemy_data.max_stamina)
		selected_attack = {}
		return {}
	var available_attacks = enemy_data.attacks.filter(func(attack): return attack.staminaCost <= enemy_data.stamina)
	if available_attacks.is_empty():
		print("no available attacks on enemy "+ str(id))
		selected_attack = {}
		change_stamina(0)
		return {}
	#get best attack
	#available_attacks.sort_custom(func(a,b): return a.staminaCost > b.staminaCost )
	#selected_attack = available_attacks[0]
	
	#get random attack
	#selected_attack = available_attacks.pick_random()
	
	#get weighted random attack based on cost
	var weighted_list = []
	for attack in available_attacks:
		for i in range(attack.staminaCost):
			weighted_list.append(attack)
	selected_attack = weighted_list.pick_random().duplicate()
	if "empowered" in enemy_data.status_effects and "damage" in selected_attack:
		selected_attack["damage"] += enemy_data.status_effects["empowered"].amount 
	return selected_attack

func _on_input(event):
	if event is InputEventMouseButton:
		if event.is_released() && is_card_selected:
			on_clicked_signal.emit(id)


func heal(amount:int) -> void:
	enemy_data.health = min(enemy_data.health+amount, enemy_data.max_health)
	update_health_bar_ui()

func _on_animation_finished(anim_name : String)-> void:
	if anim_name == "attack_rise":
		attack_rise_done.emit(id)
		set_attack_info()
	elif anim_name == "attack_end":
		attack_end_done.emit()
		remove_attack_info()
		remove_status_effect_info()
		set_status_effect_info()
		z_index = 5

func process_status_effects():
	for effect in enemy_data.status_effects.values():
		effect = effect as StatusEffectData
		if effect._name == "bleed":
			damage(effect.amount)
			add_status_effect("bleed",-1)
			

func start_attack_animation() -> void:
	z_index = 6
	#var tween = create_tween()
	#tween.tween_property(self,"position",Vector2(0,position.y),0.2)
	#await get_tree().create_timer(0.2).timeout
	animationPlayer.play("attack_rise")
	
func start_attack_end_animation() -> void:
	animationPlayer.play("attack_end")
	
func set_attack_info() -> void:
	for attack in selected_attack.keys():
		var icon = attackIcon.instantiate()
		icon.add_to_group("attack_icon")
		infoPopup.add_child(icon)
		icon.set_data(attack,selected_attack[attack],"empowered" in enemy_data.status_effects)
		infoBox.size.y = (enemy_data.status_effects.keys().size() + selected_attack.keys().size()) * 80
		infoBox.visible = true

func set_status_effect_info() -> void:
	for effect in enemy_data.status_effects.values():
		if effect.amount > 0 and !effect.hidden:
			var icon = statusEffectIcon.instantiate()
			statusEffectContainer.add_child(icon)
			icon.set_data(effect)
			icon.add_to_group("status_effect")

func remove_status_effect_info() -> void:
	for n in statusEffectContainer.get_children():
		if n.is_in_group("status_effect"):
			statusEffectContainer.remove_child(n)
			n.queue_free()

func remove_attack_info() -> void:
	for n in infoPopup.get_children():
		if n.is_in_group("attack_icon"):
			infoPopup.remove_child(n)
			n.queue_free()
	infoBox.visible = false

func add_status_effect(effect : String,amount: int) -> void:
	if effect in enemy_data.status_effects:
		if enemy_data.status_effects[effect].amount <= -amount:
			enemy_data.status_effects.erase(effect)
		else:
			if effect == "dazed" and (selected_attack == null or selected_attack == {} or !("unstoppable" in selected_attack)):
				selected_attack = {}
				remove_attack_info()
				set_attack_info()
			enemy_data.status_effects[effect].amount += amount
	else:
		if effect == "dazed" and (selected_attack == null or selected_attack == {} or !("unstoppable" in selected_attack)):
			selected_attack = {}
			remove_attack_info()
			set_attack_info()
		enemy_data.status_effects[effect] = StatusEffectData.fromDict(db.status_effects[effect],amount)
	if effect == "block":
		update_health_bar_ui()
	remove_status_effect_info()
	set_status_effect_info()
	
	
func get_status_effect(effect : String) -> StatusEffectData:
	if effect in enemy_data.status_effects:
		return enemy_data.status_effects[effect]
	return null
