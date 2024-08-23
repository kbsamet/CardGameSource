extends Node2D

@onready var enemy : EnemyNode = $Enemy
signal boss_state_changed
signal boss_phase_changed
@onready var enemyScene : PackedScene = preload("res://Scenes/enemies/Enemy.tscn")

var phase : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy.enemy_state_changed.connect(func() -> void: boss_state_changed.emit())
	enemy.boss_dead.connect(boss_dead)
	$Enemy/Control.position -= Vector2(0,20)
	$Enemy/Control.scale = Vector2(1.2,1.2)

func boss_dead() -> void:
	if phase == 0:
		enemy.sprite.texture = load("res://Sprites/enemies/vampireBlue.png")
		enemy.enemy_data = db.get_enemy("VampireBlue")
		boss_phase_changed.emit(enemy.enemy_data)
		boss_state_changed.emit()
		for i in range(2):
			var bat_node : EnemyNode = enemyScene.instantiate()
			var bat : EnemyData = db.get_enemy("Bat")
			bat_node.enemy_data = bat
			get_parent().add_enemy(bat_node)
		phase = 1
	elif phase == 1:
		enemy.die()
