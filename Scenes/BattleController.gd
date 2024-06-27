extends Control

enum Turn {
	PlayerAction,PlayerReaction, EnemyAction,EnemyReaction
}


var rng = RandomNumberGenerator.new()
var current_turn = Turn.PlayerAction
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
	enemyController._on_card_used.connect(use_card)
	enemyController.enemy_turn_done.connect(enemy_turn_done)
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
	if card_id == -1 || current_turn == Turn.EnemyAction || current_turn == Turn.EnemyReaction:
		return
	var card_effects =  hand.cards[card_id].card_data.effects
	if db.Player.ap < hand.cards[card_id].card_data.cost:
		return
	for effect in card_effects.keys():
		if effect == db.CardEffect.Damage:
			enemyController.enemies[enemy_id].damage(card_effects[effect])
	db.change_player_stat("ap",db.Player.ap - hand.cards[card_id].card_data.cost)
	hand.discard(card_id)


func end_turn_clicked():
	if current_turn == Turn.EnemyAction ||current_turn == Turn.EnemyReaction:
		return
	current_turn = Turn.EnemyAction
	enemyController.play_turn(0)

func enemy_turn_done():
	current_turn = Turn.PlayerAction
