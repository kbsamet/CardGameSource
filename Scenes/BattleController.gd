extends Control




var rng = RandomNumberGenerator.new()
@onready var playerUI = $Control/FightPlayerUI
@onready var hand = $Control/Hand
@onready var enemyController = $Control/EnemyController
@onready var fightUI = $Control/FightPlayerUI
@export var cardScene = preload("res://Scenes/Card.tscn")
@export var enemyScene = preload("res://Scenes/enemies/Enemy.tscn")

var card_selected = false
# Called when the node enters the scene tree for the first time.
func _ready():
	hand.selected_card_state_changed.connect(_on_card_select_state_changed)
	hand.play_card.connect(use_card)
	enemyController._on_card_used.connect(use_card)
	enemyController.enemy_turn_done.connect(enemy_turn_done)
	enemyController.enemy_action_done.connect(enemy_action_done)
	fightUI.end_turn_clicked.connect(end_turn_clicked)
	spawn_random_card()
	spawn_random_card()
	spawn_random_card()
	spawn_random_card()
	spawn_random_card()
	spawn_random_card()
	spawn_zombie()
	spawn_zombie()
	pass # Replace with function body.

func _on_card_select_state_changed(newstate):
	card_selected = newstate
	enemyController.set_card_selected(newstate)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func spawn_random_card():
	var card_key = db.cards.keys()[rng.randi_range(0,db.cards.keys().size() - 1)]
	var card = db.cards[card_key]
	var new_card = cardScene.instantiate()
	new_card.card_data = db.Card.new(card_key)
	hand.add_card(new_card)
	
func spawn_zombie():
	var new_zombie = enemyScene.instantiate() 
	new_zombie.enemy_data = db.Enemy.new("Zombie")
	enemyController.add_enemy(new_zombie)


func use_card(enemy_id):
	var card_id = hand.selected_card
	if card_id == -1 || db.current_turn == db.Turn.EnemyAction || db.current_turn == db.Turn.EnemyReaction:
		return
	var selected_card = hand.cards[card_id]
	var card_effects =  selected_card.card_data.effects
	if (selected_card.card_data.type == db.CardType.Action && db.Player.ap < selected_card.card_data.cost) || (selected_card.card_data.type == db.CardType.Reaction && db.Player.rp < selected_card.card_data.cost) :
		return
	if (selected_card.card_data.type == db.CardType.Action && db.current_turn == db.Turn.PlayerReaction) || (selected_card.card_data.type == db.CardType.Reaction && db.current_turn == db.Turn.PlayerAction):
		return
	for effect in card_effects.keys():
		if effect == db.CardEffect.Damage:
			enemyController.enemies[enemy_id].damage(card_effects[effect])
	if selected_card.card_data.type == db.CardType.Action:
		db.change_player_stat("ap",db.Player.ap - selected_card.card_data.cost)
	else:
		db.change_player_stat("rp",db.Player.rp - selected_card.card_data.cost)
	hand.discard(card_id)


func end_turn_clicked():
	if db.current_turn == db.Turn.EnemyAction || db.current_turn == db.Turn.EnemyReaction:
		return
	if db.current_turn == db.Turn.PlayerAction:
		db.set_turn(db.Turn.EnemyAction)
		enemyController.play_turn(0)
	else:
		db.set_turn(db.Turn.EnemyAction)
		enemyController.end_enemy_attack()
func enemy_turn_done():
	db.set_turn(db.Turn.PlayerAction)

func enemy_action_done(enemy_id):
	db.set_turn(db.Turn.PlayerReaction)
