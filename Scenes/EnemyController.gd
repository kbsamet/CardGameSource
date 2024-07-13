extends Container
class_name EnemyController

signal _on_card_used(enemy_id)
signal enemy_turn_done
signal enemy_action_done(enemy_id)
signal hovered_enemy_changed(id)
var attacking_enemy_id = -1
var enemies : Dictionary = {}
var id_count = 0
var enemy_generator 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_enemy(enemy : EnemyNode):
	enemies[id_count] = enemy
	enemy.id = id_count
	id_count += 1
	enemy.on_clicked_signal.connect(_on_enemy_clicked)
	enemy.attack_rise_done.connect(_enemy_attack_rise_done)
	enemy.attack_end_done.connect(_enemy_attack_end_done)
	enemy.enemy_dead.connect(_enemy_dead)
	enemy.enemy_hovered.connect(_on_enemy_hovered)
	enemy.enemy_hovered_end.connect(_on_enemy_hovered_end)
	
	
	add_child(enemy)
	center_enemies()

func _on_enemy_clicked(enemy_id):
	_on_card_used.emit(enemy_id)

func _on_enemy_hovered(enemy_id):
	hovered_enemy_changed.emit(enemy_id)
	
func _on_enemy_hovered_end(enemy_id):
	hovered_enemy_changed.emit(-1)
	
func center_enemies():
	if enemies.is_empty():
		return
	var enemy_sprite : Sprite2D = enemies.values()[0].find_child("Sprite")
	var enemy_width = enemy_sprite.texture.get_size().x
	var enemy_count = enemies.keys().size()
	var tween = create_tween()
	for i in range(enemy_count):
		tween.tween_property(enemies[enemies.keys()[i]],"position",Vector2((i - ((enemy_count - 1)/2.0)) * (enemy_width * (enemy_sprite.transform.get_scale().x) + 150),enemies[enemies.keys()[i]].position.y),0.2)

func set_card_selected(new_state):
	for enemy in enemies.values():
		enemy.is_card_selected = new_state
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_turn():
	var gen = ArrayIterator.Iterator.new(enemies.keys())
	enemy_generator = gen
	play_turn(gen)
	
func play_turn(gen:ArrayIterator.Iterator):
	assert(gen != null, "generator null")
	if !gen.has_next():
		enemy_turn_done.emit()
		return
	var id = gen.next()
	while !(id in enemies):
		if !gen.has_next():
			enemy_turn_done.emit()
			return
		id = gen.next()
	enemies[id].start_attack_animation()
	attacking_enemy_id = id
	

func _enemy_attack_rise_done(enemy_id):
	var enemy = enemies[enemy_id]
	enemy.get_attack()
	enemy_action_done.emit(enemy_id)

func end_enemy_attack():
	if !(attacking_enemy_id in enemies):
		_enemy_attack_end_done()
		return 
	assert(attacking_enemy_id != -1,"No enemies are attacking!")
	var attacking_enemy = enemies[attacking_enemy_id] as EnemyNode
	var attack = attacking_enemy.selected_attack
	assert(attack != null,"Enemy does not have an attack selected!")
	if attacking_enemy.get_status_effect("dazed") != null:
		attacking_enemy.add_status_effect("dazed",-1)
		attacking_enemy.start_attack_end_animation()
		return
	for key in attack.keys():
		match key:
			"damage":
				if !("dodge" in db.player.status_effects.keys()):
					db.player.damage_player(attack["damage"])
			"staminaCost":
				attacking_enemy.change_stamina(-attack["staminaCost"])
			"bleed":
				if !("block" in db.player.status_effects.keys()) and !("dodge" in db.player.status_effects.keys()):
					db.player.add_player_status_effect("bleed",attack["bleed"])
			"daze":
				if !("block" in db.player.status_effects.keys()) and !("dodge" in db.player.status_effects.keys()):
					db.player.add_player_status_effect("dazed",attack["daze"])
			"blind":
				if !("block" in db.player.status_effects.keys()) and !("dodge" in db.player.status_effects.keys()):
					db.player.add_player_status_effect("blind",attack["blind"])
			"armorUp":
				attacking_enemy.add_status_effect("block",attack["armorUp"])
			"healAll":
				for enemy in enemies.values():
					enemy.heal(attack["healAll"])
			"burn":
				if !("block" in db.player.status_effects.keys()) and !("dodge" in db.player.status_effects.keys()):
					db.player.add_player_status_effect("burn",attack["burn"])
	if "dodge" in db.player.status_effects.keys():
		db.player.add_player_status_effect("dodge",-1)
	attacking_enemy.start_attack_end_animation()

func _enemy_attack_end_done():
	center_enemies()
	play_turn(enemy_generator)
	
func _enemy_dead(enemy_id):
	remove_child(enemies[enemy_id])
	enemies[enemy_id].queue_free()
	enemies.erase(enemy_id)
	center_enemies()
	
func array_generator(arr):
	for element in arr:
		await element
