extends Container

signal _on_card_used(enemy_id)
signal enemy_turn_done
var enemies : Array[Node] = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_enemy(enemy : Node):
	enemies.append(enemy)
	enemy.on_clicked_signal.connect(_on_enemy_clicked)
	enemy.attack_rise_done.connect(_enemy_attack_rise_done)
	enemy.attack_end_done.connect(_enemy_attack_end_done)
	enemy.id = enemies.size() - 1
	add_child(enemy)
	center_enemies()

func _on_enemy_clicked(enemy_id):
	_on_card_used.emit(enemy_id)

func center_enemies():
	var enemy_sprite : Sprite2D = enemies[0].find_child("Sprite")
	var enemy_width = enemy_sprite.texture.get_size().x
	var enemy_count = enemies.size()
	var tween = create_tween()
	for i in range(enemy_count):
		# ortadaki kart 0 sol sağ +1 -1 diye gidiyo bunla sprite scale i çarpıyoruz
		tween.tween_property(enemies[i],"position",Vector2((i - ((enemy_count - 1)/2.0)) * (enemy_width * (enemy_sprite.transform.get_scale().x) + 150),enemies[i].position.y),0.2)

func set_card_selected(new_state):
	for enemy in enemies:
		enemy.is_card_selected = new_state
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_turn(enemy_id):
	if enemy_id > enemies.size() -1 :
		enemy_turn_done.emit()
		return
	enemies[enemy_id].start_attack_animation()
	

func _enemy_attack_rise_done(enemy_id):
	var enemy = enemies[enemy_id]
	var attack = enemy.get_attack()
	for key in attack.keys():
		if key == "damage":
			db.change_player_stat("health",db.Player.health - attack["damage"])
	enemies[enemy_id].start_attack_end_animation()

func _enemy_attack_end_done(enemy_id):
	center_enemies()
	await get_tree().create_timer(0.2).timeout
	play_turn(enemy_id+1)
