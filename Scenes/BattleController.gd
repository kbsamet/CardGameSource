extends Control


@onready var playerUI = $Control/FightPlayerUI
@onready var hand = $Control/Hand
@onready var enemyController = $Control/EnemyController
@onready var fightUI = $Control/FightPlayerUI
@export var enemyScene = preload("res://Scenes/enemies/Enemy.tscn")

var card_selected = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if db.Player.deck.is_empty():
		create_deck()
	hand.selected_card_state_changed.connect(_on_card_select_state_changed)
	hand.play_card.connect(_use_card)
	enemyController._on_card_used.connect(_use_card)
	enemyController.enemy_turn_done.connect(_enemy_turn_done)
	enemyController.enemy_action_done.connect(_enemy_action_done)
	fightUI.end_turn_clicked.connect(_end_turn_clicked)
	hand.deal_hand()
	spawn_zombie()
	spawn_zombie()
	pass # Replace with function body.

func _on_card_select_state_changed(newstate):
	card_selected = newstate
	enemyController.set_card_selected(newstate)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func spawn_zombie():
	var new_zombie = enemyScene.instantiate() 
	new_zombie.enemy_data = db.Enemy.new("Zombie")
	enemyController.add_enemy(new_zombie)


func _use_card(enemy_id):
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
		elif effect == db.CardEffect.Block:
			if "block" in db.Player.statusEffects:
				db.change_player_status_effect("block", db.Player.statusEffects.block + card_effects[effect])
			else:
				db.change_player_status_effect("block", card_effects[effect])
				
	if selected_card.card_data.type == db.CardType.Action:
		db.change_player_stat("ap",db.Player.ap - selected_card.card_data.cost)
	else:
		db.change_player_stat("rp",db.Player.rp - selected_card.card_data.cost)
	hand.discard(card_id)


func _end_turn_clicked():
	if db.current_turn == db.Turn.EnemyAction || db.current_turn == db.Turn.EnemyReaction:
		return
	if db.current_turn == db.Turn.PlayerAction:
		db.set_turn(db.Turn.EnemyAction)
		enemyController.start_turn()
	else:
		db.set_turn(db.Turn.EnemyAction)
		enemyController.end_enemy_attack()
		
func _enemy_turn_done():
	db.change_player_stat("ap", db.Player.maxAp)
	db.change_player_stat("rp", db.Player.maxRp)
	db.set_turn(db.Turn.PlayerAction)
	hand.deal_hand()

func _enemy_action_done(enemy_id):
	db.set_turn(db.Turn.PlayerReaction)

func create_deck():
	for i in range(5):
		db.Player.deck.push_back(db.Card.new("Strike"))
		db.Player.deck.push_back(db.Card.new("Block"))
	fightUI.update_ui_values()

