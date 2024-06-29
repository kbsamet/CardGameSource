extends Control

@onready var hand : Hand  = $Control/Hand
@onready var enemyController : EnemyController = $Control/EnemyController
@onready var fightUI : PlayerUI= $Control/FightPlayerUI
@export var enemyScene = preload("res://Scenes/enemies/Enemy.tscn")

var card_selected = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if db.player.deck.is_empty():
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
	new_zombie.enemy_data = EnemyData.fromDict(db.enemies["Zombie"]) 
	enemyController.add_enemy(new_zombie)


func _use_card(enemy_id):
	var card_id = hand.selected_card
	if card_id == -1 || db.current_turn == db.Turn.EnemyAction || db.current_turn == db.Turn.EnemyReaction:
		return
	var selected_card = hand.cards[card_id]
	
	var card_effects =  selected_card.card_data.effects
	if (selected_card.card_data.type == db.CardType.Action && db.player.ap < selected_card.card_data.cost) || (selected_card.card_data.type == db.CardType.Reaction && db.player.rp < selected_card.card_data.cost) :
		return
	if (selected_card.card_data.type == db.CardType.Action && db.current_turn == db.Turn.PlayerReaction) || (selected_card.card_data.type == db.CardType.Reaction && db.current_turn == db.Turn.PlayerAction):
		return
	for effect in card_effects.keys():
		if effect == db.CardEffect.Damage:
			enemyController.enemies[enemy_id].damage(card_effects[effect])
		elif effect == db.CardEffect.Block:
			if "block" in db.player.status_effects:
				db.player.change_player_status_effect("block", db.player.status_effects.block + card_effects[effect])
			else:
				db.player.change_player_status_effect("block", card_effects[effect])
		elif effect == db.CardEffect.Daze:
			if enemy_id in enemyController.enemies:
				enemyController.enemies[enemy_id].add_status_effect("dazed", 1)
	if selected_card.card_data.type == db.CardType.Action:
		db.player.ap = db.player.ap - selected_card.card_data.cost
		db.player_state_changed.emit()
	else:
		db.player.rp = db.player.rp - selected_card.card_data.cost
		db.player_state_changed.emit()
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
	if enemyController.enemies.is_empty():
		spawn_zombie()
		spawn_zombie()
		spawn_zombie()
		
func _enemy_turn_done():
	db.player.ap = db.player.max_ap
	db.player.rp = db.player.max_rp
	db.player_state_changed.emit()
	db.player.end_turn_process_player_status_effects()
	db.check_game_over()
	db.set_turn(db.Turn.PlayerAction)
	hand.discard_all()
	hand.deal_hand()

func _enemy_action_done(enemy_id):
	db.set_turn(db.Turn.PlayerReaction)

func create_deck():
	for i in range(4):
		db.player.deck.push_back(CardData.from_dict(db.cards["Strike"]))
		db.player.deck.push_back(CardData.from_dict(db.cards["Block"]))
	db.player.deck.push_back(CardData.from_dict(db.cards["Shield Bash"]))
	db.player.deck.push_back(CardData.from_dict(db.cards["Daze"]))
	fightUI.update_ui_values()

