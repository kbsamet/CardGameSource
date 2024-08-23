extends Container
class_name EnemyController

signal _on_card_used(enemy_id : int)
signal enemy_turn_done
signal enemies_empty
signal enemy_action_done(enemy_id : int)
signal hovered_enemy_changed(id : int)
var attacking_enemy_id : int = -1
var enemies : Dictionary = {}
var id_count : int = 0 
var enemy_generator : ArrayIterator.Iterator

func add_boss(boss : Node2D) -> void:
	add_child(boss)
	enemies[id_count] = boss.enemy
	boss.enemy.id = id_count
	id_count += 1
	boss.enemy.on_clicked_signal.connect(_on_enemy_clicked)
	boss.enemy.attack_rise_done.connect(_enemy_attack_rise_done)
	boss.enemy.attack_end_done.connect(_enemy_attack_end_done)
	boss.enemy.enemy_dead.connect(_boss_dead)
	boss.enemy.enemy_hovered.connect(_on_enemy_hovered)
	boss.enemy.enemy_hovered_end.connect(_on_enemy_hovered_end)
	center_enemies()
	
func add_enemy(enemy : EnemyNode) -> void:
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

func _on_enemy_clicked(enemy_id : int) -> void:
	_on_card_used.emit(enemy_id)

func _on_enemy_hovered(enemy_id : int) -> void:
	hovered_enemy_changed.emit(enemy_id)
	
func _on_enemy_hovered_end(enemy_id : int) -> void:
	hovered_enemy_changed.emit(-1)
	
func center_enemies() -> void:
	if enemies.is_empty():
		return
	var enemy_count : int = enemies.keys().size()
	var tween : Tween = create_tween()
	var enemies_reordered : Array[int] = []
	var boss_key : int = -1
	for enemy_id : int in enemies.keys(): 
		if enemies[enemy_id].is_boss:
			boss_key = enemy_id
		else:
			enemies_reordered.append(enemy_id)
	if boss_key != -1:
		enemies_reordered.insert(enemy_count/2,boss_key)
	for i in range(enemy_count):
		if enemies_reordered[i] in enemies:
			var new_count : int = enemy_count + 1 if boss_key != -1 and enemy_count % 2 == 0 else enemy_count
			var enemy_sprite : Sprite2D = enemies.values()[0].find_child("Sprite")
			var enemy_width : float = enemy_sprite.texture.get_size().x
			tween.tween_property(enemies[enemies_reordered[i]],"position:x",(i - ((new_count - 1)/2.0)) * (enemy_width * (enemy_sprite.transform.get_scale().x) + 150),0.2)

func set_card_selected(new_state : bool) -> void:
	for enemy : EnemyNode in enemies.values():
		enemy.is_card_selected = new_state

func start_turn()-> void:
	if enemies.is_empty():
		enemies_empty.emit()
		return
	for enemy : EnemyNode in enemies.values():
		enemy.process_status_effects()
	var gen : ArrayIterator.Iterator = ArrayIterator.Iterator.new(enemies.keys())
	enemy_generator = gen
	play_turn(gen)
	
func play_turn(gen:ArrayIterator.Iterator) -> void:
	assert(gen != null, "generator null")
	if !gen.has_next():
		enemy_turn_done.emit()
		return
	var id : int = gen.next()
	while !(id in enemies):
		if !gen.has_next():
			enemy_turn_done.emit()
			return
		id = gen.next()
	enemies[id].start_attack_animation()
	attacking_enemy_id = id
	

func _enemy_attack_rise_done(enemy_id : int) -> void:
	var enemy : EnemyNode = enemies[enemy_id]
	enemy.get_attack()
	enemy_action_done.emit(enemy_id)
func end_enemy_attack() -> void:
	if !(attacking_enemy_id in enemies):
		_enemy_attack_end_done()
		return 
	assert(attacking_enemy_id != -1,"No enemies are attacking!")
	var attacking_enemy : EnemyNode = enemies[attacking_enemy_id]
	var attack : EnemyAttackData = attacking_enemy.selected_attack
	var dazed_status : StatusEffectData = attacking_enemy.get_status_effect("dazed")
	if dazed_status != null:
		if dazed_status.amount == 1:
			if attacking_enemy.enemy_data.stamina == 0:
				attacking_enemy.change_stamina(attacking_enemy.enemy_data.max_stamina)
		attacking_enemy.add_status_effect("dazed",-1)
		attacking_enemy.start_attack_end_animation()
		return
	if attack == null:
		attacking_enemy.start_attack_end_animation()
		return
	var unblockable : bool = true if attack.get_value_of_type(db.EnemyAttack.Unblockable) != -1 else false
	for single_attack in attack.attacks:
		single_attack = single_attack as EnemySingleAttackData
		match single_attack.attack_type:
			db.EnemyAttack.Damage:
				if !("dodge" in db.player.status_effects.keys() and db.player.status_effects["dodge"].amount > 0):
					if "dodge_chance" in db.player.status_effects:
						if db.player.status_effects["dodge_chance"].amount > randi_range(0,100):
							db.screen_effect.emit("dodged")
							continue
					if "block" in db.player.status_effects and "barbedshield" in db.player.status_effects:
						attacking_enemy.add_status_effect("bleed",min(single_attack.amount,db.player.status_effects["block"].amount))
					db.player.damage_player(single_attack.amount,unblockable)
				else:
					db.screen_effect.emit("dodged")
			db.EnemyAttack.StaminaCost:
				attacking_enemy.change_stamina(-single_attack.amount)
			db.EnemyAttack.Bleed:
				if unblockable or !("block" in db.player.status_effects.keys() and db.player.status_effects["block"].amount > 0):
					if !("dodge" in db.player.status_effects.keys() and db.player.status_effects["dodge"].amount > 0):
						if "dodge_chance" in db.player.status_effects:
							if db.player.status_effects["dodge_chance"].amount > randi_range(0,100):
								db.screen_effect.emit("dodged")
								continue
						db.player.add_player_status_effect("bleed",single_attack.amount)
					else:
						db.screen_effect.emit("dodged")
			db.EnemyAttack.Daze:
				if unblockable or !("block" in db.player.status_effects.keys() and db.player.status_effects["block"].amount > 0):
					if !("dodge" in db.player.status_effects.keys() and db.player.status_effects["dodge"].amount > 0):
						if "dodge_chance" in db.player.status_effects:
							if db.player.status_effects["dodge_chance"].amount > randi_range(0,100):
								db.screen_effect.emit("dodged")
								continue
						db.player.add_player_status_effect("dazed",single_attack.amount)
					else:
						db.screen_effect.emit("dodged")
			db.EnemyAttack.Blind:
				if unblockable or !("block" in db.player.status_effects.keys() and db.player.status_effects["block"].amount > 0):
					if !("dodge" in db.player.status_effects.keys() and db.player.status_effects["dodge"].amount > 0):
						if "dodge_chance" in db.player.status_effects:
							if db.player.status_effects["dodge_chance"].amount > randi_range(0,100):
								db.screen_effect.emit("dodged")
								continue
						db.player.add_player_status_effect("blind",single_attack.amount)
					else:
						db.screen_effect.emit("dodged")
			db.EnemyAttack.ArmorUp:
				attacking_enemy.add_status_effect("block",single_attack.amount)
			db.EnemyAttack.HealAll:
				for enemy : EnemyNode in enemies.values():
					enemy.heal(single_attack.amount)
			db.EnemyAttack.Burn:
				if unblockable or !("block" in db.player.status_effects.keys() and db.player.status_effects["block"].amount > 0):
					if !("dodge" in db.player.status_effects.keys() and db.player.status_effects["dodge"].amount > 0):
						if "dodge_chance" in db.player.status_effects:
							if db.player.status_effects["dodge_chance"].amount > randi_range(0,100):
								db.screen_effect.emit("dodged")
								continue
						db.player.add_player_status_effect("burn",single_attack.amount)
					else:
						db.screen_effect.emit("dodged")
			db.EnemyAttack.Empower:
				for enemy : EnemyNode in enemies.values():
					enemy.add_status_effect("empowered",single_attack.amount)
			db.EnemyAttack.Lifesteal:
				if !("dodge" in db.player.status_effects.keys() and db.player.status_effects["dodge"].amount > 0):
					if "dodge_chance" in db.player.status_effects:
						if db.player.status_effects["dodge_chance"].amount > randi_range(0,100):
							db.screen_effect.emit("dodged")
							continue
					db.player.damage_player(single_attack.amount,unblockable)
					attacking_enemy.heal(single_attack.amount)
				else:
					db.screen_effect.emit("dodged")
			db.EnemyAttack.DrainAp:
				if unblockable or !("block" in db.player.status_effects.keys() and db.player.status_effects["block"].amount > 0):
					if !("dodge" in db.player.status_effects.keys() and db.player.status_effects["dodge"].amount > 0):
						if "dodge_chance" in db.player.status_effects:
							if db.player.status_effects["dodge_chance"].amount > randi_range(0,100):
								db.screen_effect.emit("dodged")
								continue
						db.player.add_player_status_effect("drainAp",single_attack.amount)
					else:
						db.screen_effect.emit("dodged")
			db.EnemyAttack.DrainRp:
				if unblockable or !("block" in db.player.status_effects.keys() and db.player.status_effects["block"].amount > 0):
					if !("dodge" in db.player.status_effects.keys() and db.player.status_effects["dodge"].amount > 0):
						if "dodge_chance" in db.player.status_effects:
							if db.player.status_effects["dodge_chance"].amount > randi_range(0,100):
								db.screen_effect.emit("dodged")
								continue
						db.player.add_player_status_effect("drainRp",single_attack.amount)
					else:
						db.screen_effect.emit("dodged")
			db.EnemyAttack.Unstoppable:
				attacking_enemy.add_status_effect("unstoppable",single_attack.amount)
					
	if "dodge" in db.player.status_effects.keys() and db.player.status_effects["dodge"].amount > 0:
		db.player.add_player_status_effect("dodge",-1)
	attacking_enemy.start_attack_end_animation()

func _enemy_attack_end_done() -> void:
	center_enemies()
	play_turn(enemy_generator)

func _boss_dead(enemy_id : int) -> void:
	var boss : Node2D = enemies[enemy_id].get_parent()
	remove_child(boss)
	boss.queue_free()
	enemies.erase(enemy_id)
	if enemies.is_empty():
		enemies_empty.emit()
	center_enemies()
func _enemy_dead(enemy_id : int) -> void:
	remove_child(enemies[enemy_id])
	enemies[enemy_id].queue_free()
	enemies.erase(enemy_id)
	if enemies.is_empty():
		enemies_empty.emit()
	center_enemies()
	
