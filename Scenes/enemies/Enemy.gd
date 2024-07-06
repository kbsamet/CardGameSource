extends Node2D

var enemy_data : EnemyData
var is_card_selected = false
var id : int
signal on_clicked_signal(id)
signal attack_rise_done(id)
signal attack_end_done(id)
signal enemy_dead(id)
@onready var sprite = $Sprite
@onready var healthBarRect = $Control/HealthBar/HealthBarRect
@onready var healthLabel = $Control/HealthBar/HealthLabel
@onready var staminaBarRect = $Control/StaminaBar/StaminaBarRect
@onready var staminaLabel = $Control/StaminaBar/StaminaLabel
@onready var animationPlayer = $AnimationPlayer
@onready var outlineShader = preload("res://Shaders/outline_red.tres")
@onready var attackIcon = preload("res://Scenes/ui/EnemyAttackIcon.tscn")
@onready var statusEffectIcon = preload("res://Scenes/ui/StatusEffectIcon.tscn")
@onready var infoPopup = $Control/InfoPopup
@onready var infoBox = $Control/InfoBox

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
func damage(amount):
	var tween =  create_tween()
	enemy_data.health -= amount
	tween.tween_property(healthBarRect,"size:x", (float(enemy_data.health) / float(enemy_data.max_health)) * float(health_bar_full_width),0.2)
	healthLabel.text = str(enemy_data.health) + "/" + str(enemy_data.max_health)
	if enemy_data.health <= 0:
		enemy_dead.emit(id)
func _on_hover():
	if is_card_selected:
		sprite.material = outlineShader


func _on_hover_end() -> void:
	sprite.material = null

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
	selected_attack = weighted_list.pick_random()
	return selected_attack

func _on_input(event):
	if event is InputEventMouseButton:
		if event.is_released() && is_card_selected:
			on_clicked_signal.emit(id)


func _on_animation_finished(anim_name : String)-> void:
	if anim_name == "attack_rise":
		attack_rise_done.emit(id)
		set_attack_info()
	elif anim_name == "attack_end":
		attack_end_done.emit()
		remove_attack_info()
		z_index = 5

func start_attack_animation() -> void:
	z_index = 6
	var tween = create_tween()
	tween.tween_property(self,"position",Vector2(0,position.y),0.2)
	await get_tree().create_timer(0.2).timeout
	animationPlayer.play("attack_rise")
	
func start_attack_end_animation() -> void:
	animationPlayer.play("attack_end")
	
func set_attack_info() -> void:
	for attack in selected_attack.keys():
		var icon = attackIcon.instantiate()
		icon.add_to_group("attack_icon")
		infoPopup.add_child(icon)
		icon.set_data(attack,selected_attack[attack])
		infoBox.size.y = (enemy_data.status_effects.keys().size() + selected_attack.keys().size()) * 80
		infoBox.visible = true

func set_status_effect_info() -> void:
	for effect in enemy_data.status_effects.values():
		var icon = statusEffectIcon.instantiate()
		icon.add_to_group("status_effect")
		infoPopup.add_child(icon)
		icon.set_data(effect)

func remove_status_effect_info() -> void:
	for n in infoPopup.get_children():
		if n.is_in_group("status_effect"):
			infoPopup.remove_child(n)
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
			if effect == "dazed":
				selected_attack = {}
				remove_attack_info()
				set_attack_info()
			enemy_data.status_effects[effect].amount += amount
	else:
		if effect == "dazed":
			selected_attack = {}
			remove_attack_info()
			set_attack_info()
		enemy_data.status_effects[effect] = StatusEffectData.fromDict(db.status_effects[effect],amount)
	remove_status_effect_info()
	set_status_effect_info()
	
	
func get_status_effect(effect : String) -> StatusEffectData:
	if effect in enemy_data.status_effects:
		return enemy_data.status_effects[effect]
	return null
