extends Node2D
class_name EnemyNode
@export var enemy_data : EnemyData
var is_card_selected : bool = false
var id : int
var hit_animation_playing: bool = false
var death_animation_playing : bool= false
signal on_clicked_signal(id: int)
signal attack_rise_done(id: int)
signal attack_end_done(id: int)
signal enemy_dead(id: int)
signal enemy_hovered(id: int)
signal enemy_hovered_end(id: int)
signal enemy_state_changed
signal boss_dead
@onready var sprite : Sprite2D = $Sprite
@onready var blockSprite : Sprite2D = $Control/HealthBar/BlockIcon
@onready var blockAmountLabel : Label= $Control/HealthBar/BlockIcon/Label
@onready var healthBarSprite : Sprite2D = $Control/HealthBar
@onready var healthBarRect : ColorRect = $Control/HealthBar/HealthBarRect
@onready var healthLabel : Label = $Control/HealthBar/HealthLabel
@onready var blockBarRect : ColorRect = $Control/HealthBar/BlockBarRect
@onready var staminaBarRect : ColorRect = $Control/StaminaBar/StaminaBarRect
@onready var staminaLabel : Label = $Control/StaminaBar/StaminaLabel
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var statusEffectContainer : HBoxContainer = $Control/StatusEffectContainer
@onready var hitShader : ShaderMaterial = preload("res://Shaders/hit_shader.tres").duplicate()
@onready var outlineShader: ShaderMaterial = preload("res://Shaders/outline_red.tres")
@onready var attackIcon: PackedScene = preload("res://Scenes/ui/EnemyAttackIcon.tscn")
@onready var statusEffectIcon : PackedScene= preload("res://Scenes/ui/StatusEffectIcon.tscn")
@onready var infoPopup : VBoxContainer = $Control/InfoPopup
@onready var infoBox : Panel = $Control/InfoBox
@onready var hitAmountLabel : Label = $Control/HitAmount
@onready var blockHitAmountLabel : Label = $Control/BlockAmount
@onready var hitParticles : CPUParticles2D = $HitParticles
@onready var deathParticles : GPUParticles2D = $DeathParticles
@onready var lightOccluder : LightOccluder2D = $LightOccluder2D
var particle_color_red : Color = Color("ca5954")
var particle_color_blue: Color  = Color("5c699f")

@export var is_boss : bool = false
var stamina_bar_full_width : float
var health_bar_full_width : float
var selected_attack : EnemyAttackData = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = load("res://Sprites/enemies/"+enemy_data._name+".png")
	sprite.material = sprite.material.duplicate()
	healthLabel.text = str(enemy_data.health) + "/" + str(enemy_data.max_health)
	staminaLabel.text = str(enemy_data.stamina) + "/" + str(enemy_data.max_stamina)
	health_bar_full_width = healthBarRect.size.x
	stamina_bar_full_width = staminaBarRect.size.x
	var new_material : Material = deathParticles.process_material.duplicate(true)
	new_material.set_shader_parameter("sprite",sprite.texture)
	if sprite.texture.get_height() > 100:
		var new_box : Vector3 = Vector3(30,60,1)
		if sprite.texture.get_height() > 200:
			new_box = Vector3(60,120,1)
		new_material.set_shader_parameter("emission_box_extents",new_box)
	deathParticles.process_material = new_material
	lightOccluder.occluder = enemy_data.occluder
	if is_boss:
		healthBarSprite.visible = false
		healthBarRect.visible = false
		$Control/StaminaBar.visible = false
		staminaBarRect.visible = false
		staminaLabel.visible = false
	set_status_effect_info()
	update_health_bar_ui()
		
		#lightOccluder.visible = false

func change_stamina(amount:int) -> void:
	var tween : Tween =  create_tween()
	enemy_data.stamina += amount
	tween.tween_property(staminaBarRect,"size:x", (float(enemy_data.stamina) / float(enemy_data.max_stamina)) * float(stamina_bar_full_width),0.2)
	staminaLabel.text = str(enemy_data.stamina) + "/" + str(enemy_data.max_stamina)
	enemy_state_changed.emit()
	if enemy_data.stamina == 0:
		add_status_effect("dazed",1)


func update_health_bar_ui() -> void:
	enemy_state_changed.emit()
	var tween :Tween =  create_tween()
	var max_health_bar_amount: float= float(enemy_data.max_health)
	var block_amount : int = enemy_data.get_status_effect("block")
	if block_amount != -1:
		blockSprite.visible = true
		blockAmountLabel.text = str(block_amount)
		var block_bar_width : float = (float(block_amount) / (max_health_bar_amount + float(block_amount))) * health_bar_full_width
		var missing_health_width : float = (float(max_health_bar_amount - enemy_data.health) /max_health_bar_amount) * health_bar_full_width
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

func die() -> void:
	death_animation_playing = true
	$Control.visible = false
	deathParticles.emitting = true
	var tween : Tween = create_tween()
	tween.tween_property(sprite,"modulate:a",0,0.1)
	

func damage(amount : int) -> void:
	if !is_inside_tree():
		return
	var tween : Tween = create_tween()
	var block_amount : int = enemy_data.get_status_effect("block")
	if block_amount != -1:
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
		if !animationPlayer.is_playing():
			animationPlayer.play("hit")
			hitParticles.color = particle_color_red
			hitParticles.emitting = true


	enemy_data.health -= amount
	if !hit_animation_playing:
		hit_animation_playing = true
		sprite.material.set_shader_parameter("hit",true)
		tween.tween_method(func(value : float) -> void: sprite.material.set_shader_parameter("time", value),0.0,1.0,0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(func() -> void: hit_animation_playing = false)
		tween.tween_callback(func() -> void: sprite.material.set_shader_parameter("hit",false))
	update_health_bar_ui()
	if enemy_data.health <= 0:
		if is_boss:
			boss_dead.emit()
			return
		die()
	
func _on_hover() -> void:
	enemy_hovered.emit(id)
	if is_card_selected:
		sprite.material.set_shader_parameter("outline",true)


func _on_hover_end() -> void:
	sprite.material.set_shader_parameter("outline",false)
	enemy_hovered_end.emit(id)

func get_attack() -> EnemyAttackData:
	var dazed : StatusEffectData = get_status_effect("dazed")
	var dazed_amount : Variant = null if dazed == null else dazed.amount
	if dazed_amount != null:
		selected_attack = null
		return null
	var available_attacks : Array[EnemyAttackData] = enemy_data.attacks.filter(func(attack : EnemyAttackData) -> bool: return attack.get_stamina_cost() <= enemy_data.stamina)
	if enemy_data.stamina > 1:
		available_attacks = available_attacks.filter(func(attack: EnemyAttackData) -> bool: return attack.get_stamina_cost() != 1)
	if available_attacks.is_empty():
		print("no available attacks on enemy "+ str(id))
		selected_attack = null
		change_stamina(0)
		return null
	#get best attack
	#available_attacks.sort_custom(func(a,b): return a.staminaCost > b.staminaCost )
	#selected_attack = available_attacks[0]
	
	#get random attack
	selected_attack = available_attacks.pick_random()
	
	#get weighted random attack based on cost
	#var weighted_list = []
	#for attack in available_attacks:
		#attack = attack as EnemyAttackData
		#for i in range(attack.get_stamina_cost()):
			#weighted_list.append(attack)
	#selected_attack = weighted_list.pick_random().duplicate() as EnemyAttackData
	assert(selected_attack != null, "Couldn't get attack!")
	return selected_attack

func _on_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() && is_card_selected:
			on_clicked_signal.emit(id)
			db.clickPlayer.play()


func heal(amount:int) -> void:
	enemy_data.health = min(enemy_data.health+amount, enemy_data.max_health)
	update_health_bar_ui()

func _on_animation_finished(anim_name : String)-> void:
	if anim_name == "attack_rise":
		print(str(id) + " attack rise finished")
		attack_rise_done.emit(id)
		set_attack_info()
		
	elif anim_name == "attack_end":
		print(str(id) + " attack end finished")
		attack_end_done.emit()
		remove_attack_info()
		remove_status_effect_info()
		set_status_effect_info()
		z_index = 5

func process_status_effects() -> void:
	for effect : StatusEffectData in enemy_data.status_effects:
		if effect._name == "bleed":
			damage(effect.amount)
			add_status_effect("bleed",-1)
		if effect._name == "unstoppable":
			add_status_effect("unstoppable",-1)
		if effect._name == "empowered":
			add_status_effect("empowered",-1)

func start_attack_animation() -> void:
	z_index = 6
	#var tween = create_tween()
	#tween.tween_property(self,"position",Vector2(0,position.y),0.2)
	#await get_tree().create_timer(0.2).timeout
	hitAmountLabel.visible = false
	blockHitAmountLabel.visible = false
	animationPlayer.play("attack_rise")
	
func start_attack_end_animation() -> void:
	hitAmountLabel.visible = false
	blockHitAmountLabel.visible = false
	animationPlayer.play("attack_end")
	
func set_attack_info() -> void:
	if selected_attack == null:
		return
	for attack in selected_attack.attacks:
		attack = attack as EnemySingleAttackData
		var icon : AttackIcon = attackIcon.instantiate()
		icon.add_to_group("attack_icon")
		infoPopup.add_child(icon)
		icon.set_data(attack,enemy_data.get_status_effect("empowered"))
		infoBox.size.y = selected_attack.attacks.size() * 80
		infoBox.visible = true

func set_status_effect_info() -> void:
	for effect : StatusEffectData in enemy_data.status_effects:
		if effect.amount > 0 and !effect.hidden:
			var icon : StatusEffectIcon = statusEffectIcon.instantiate()
			statusEffectContainer.add_child(icon)
			icon.set_data(effect,Vector2(2,2))
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
	var past_effect_amount : int = enemy_data.get_status_effect(effect)
	if past_effect_amount != -1 and past_effect_amount <= -amount:
		if effect == "dazed":
			sprite.material.set_shader_parameter("dazed",false)
		enemy_data.remove_status_effect(effect)
	else:
		if effect == "dazed":
			if enemy_data.stamina > 0 and enemy_data.get_status_effect("unstoppable") != -1:
				return
			else:
				sprite.material.set_shader_parameter("dazed",true)
				selected_attack = null
				remove_attack_info()
				set_attack_info()
		enemy_data.add_status_effect(effect,amount)
	
	if effect == "block":
		update_health_bar_ui()
	remove_status_effect_info()
	set_status_effect_info()
	
func get_status_effect(effect : String) -> StatusEffectData:
	return enemy_data.get_status_effect_data(effect)


func _on_death_particles_finished() -> void:
	enemy_dead.emit(id)
