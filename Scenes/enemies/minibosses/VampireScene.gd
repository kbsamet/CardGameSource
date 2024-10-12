extends Node2D

@onready var enemy : EnemyNode = $Enemy
signal boss_state_changed
signal boss_phase_changed
@onready var enemyScene : PackedScene = preload("res://Scenes/enemies/Enemy.tscn")

var bossTalkCallback : Callable
var phase : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy.enemy_state_changed.connect(func() -> void: boss_state_changed.emit())
	enemy.boss_dead.connect(boss_dead)
	$Enemy/Control.position -= Vector2(0,20)
	$Enemy/Control.scale = Vector2(1.2,1.2)

func boss_dead() -> void:
	if phase == 0:
		db.current_turn = db.Turn.EnemyAction
		enemy.sprite.texture = load("res://Sprites/enemies/VampireDead.png")
		await get_tree().create_timer(2).timeout
		await bossTalkCallback.call("It is not over yet")
		await bossTalkCallback.call("You wil pay for this") 
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
		db.current_turn = db.Turn.PlayerAction
	elif phase == 1:
		enemy.die()
		db.player.health = db.player.max_health
		db.player.mana = db.player.max_mana
		db.player_state_changed.emit()
