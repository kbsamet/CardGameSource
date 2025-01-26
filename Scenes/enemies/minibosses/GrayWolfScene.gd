extends Node2D
@onready var enemy : EnemyNode = $Enemy
signal boss_state_changed
@onready var enemyScene : PackedScene = preload("res://Scenes/enemies/Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy.enemy_state_changed.connect(func() -> void: boss_state_changed.emit())
	enemy.boss_dead.connect(boss_dead)
	$Enemy/Control.position -= Vector2(0,10)
	$Enemy/Control.scale = Vector2(1.2,1.2)

func boss_dead() -> void:
	enemy.die()
	if db.player.last_played_card == "Skinning Knife":
		db.player.add_to_deck(db.get_card("Wolf Pelt"))
		db.player.remove_from_deck(db.get_card("Skinning Knife"))
		db.saveData.soulbound_cards.append("Wolf Pelt")
		db.saveData.soulbound_cards.erase("Skinning Knife")
		db.saveData.save_game()
	db.player.health = db.player.max_health
	db.player.mana = db.player.max_mana
	db.player_state_changed.emit()
