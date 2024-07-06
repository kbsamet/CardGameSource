extends Control
class_name BattleController
@onready var hand : Hand  = $Control/Hand
@onready var enemyController : EnemyController = $Control/EnemyController
@onready var fightUI : PlayerUI= $Control/FightPlayerUI
var enemyScene = preload("res://Scenes/enemies/Enemy.tscn")
var rewardScene = preload("res://Scenes/screens/RewardScreen.tscn")
var reward : RewardData
var card_selected = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if db.player.deck.is_empty() && db.player.discardPile.is_empty():
		create_deck()
	hand.selected_card_state_changed.connect(_on_card_select_state_changed)
	hand.play_card.connect(_use_card)
	enemyController._on_card_used.connect(_use_card)
	enemyController.enemy_turn_done.connect(_enemy_turn_done)
	enemyController.enemy_action_done.connect(_enemy_action_done)
	fightUI.end_turn_clicked.connect(_end_turn_clicked)
	hand.discardPosition = fightUI.discardPile.global_position
	hand.deal_hand()
	spawn_enemies()
	pass # Replace with function body.

func _on_card_select_state_changed(newstate):
	card_selected = newstate
	enemyController.set_card_selected(newstate)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func spawn_enemy(enemy_name : String):
	var new_enemy = enemyScene.instantiate() 
	new_enemy.enemy_data = EnemyData.fromDict(db.enemies[enemy_name]) 
	enemyController.add_enemy(new_enemy)

func spawn_enemies():
	var room = db.fight_rooms.pick_random() as Dictionary
	for key in room.keys():
		for value in room[key]:
			spawn_enemy(key)

func _use_card(enemy_id):
	var card_id = hand.selected_card
	if card_id == -1 || db.current_turn == db.Turn.EnemyAction || db.current_turn == db.Turn.EnemyReaction:
		return
	var selected_card = hand.cards[card_id].card_data as CardData
	if selected_card.targeted && enemyController.attacking_enemy_id != -1 && enemyController.attacking_enemy_id != enemy_id:
		return
	var card_effects =  selected_card.effects
	if (selected_card.type == db.CardType.Action && db.player.ap < selected_card.cost) || (selected_card.type == db.CardType.Reaction && db.player.rp < selected_card.cost) :
		return
	if (selected_card.type == db.CardType.Action && db.current_turn == db.Turn.PlayerReaction) || (selected_card.type == db.CardType.Reaction && db.current_turn == db.Turn.PlayerAction):
		return
	for effect in card_effects.keys():
		match effect:
			db.CardEffect.Damage:
				enemyController.enemies[enemy_id].damage(card_effects[effect])
			db.CardEffect.Block:
				if "block" in db.player.status_effects:
					db.player.change_player_status_effect("block", db.player.status_effects.block.amount + card_effects[effect])
				else:
					db.player.change_player_status_effect("block", card_effects[effect])
			db.CardEffect.Daze:
				if enemy_id in enemyController.enemies:
					enemyController.enemies[enemy_id].add_status_effect("dazed", 1)
			db.CardEffect.Bleed:
				if enemy_id in enemyController.enemies:
					enemyController.enemies[enemy_id].add_status_effect("bleed", card_effects[effect])
			db.CardEffect.Heal:
				db.player.heal_player(card_effects[effect])
			db.CardEffect.Dodge:
				db.player.add_player_status_effect("dodge",1)
			db.CardEffect.DamageAll:
				for enemy in enemyController.enemies.values():
					enemy.damage(card_effects[effect])
	if selected_card.type == db.CardType.Action:
		db.player.ap = db.player.ap - selected_card.cost
		db.player_state_changed.emit()
	else:
		db.player.rp = db.player.rp - selected_card.cost
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
		hand.discard_all()
		var reward_scene = rewardScene.instantiate() as RewardScreen
		reward_scene.reward_data = reward
		get_tree().root.add_child(reward_scene)
		get_tree().current_scene = reward_scene
		queue_free()

func _enemy_turn_done():
	db.player.ap = db.player.max_ap
	db.player.rp = db.player.max_rp
	db.player_state_changed.emit()
	db.player.end_turn_process_player_status_effects()
	db.check_game_over()
	db.set_turn(db.Turn.PlayerAction)
	enemyController.attacking_enemy_id = -1
	hand.discard_all()
	hand.deal_hand()
	if "dazed" in db.player.status_effects:
		db.player.add_player_status_effect("dazed", -1)
		db.set_turn(db.Turn.EnemyAction)
		enemyController.start_turn()
		

func _enemy_action_done(enemy_id):
	db.set_turn(db.Turn.PlayerReaction)

func create_deck():
	for i in range(4):
		db.player.deck.push_back(CardData.from_dict(db.cards["Strike"]))
		db.player.deck.push_back(CardData.from_dict(db.cards["Block"]))
	db.player.deck.push_back(CardData.from_dict(db.cards["Daze"]))
	db.player.deck.push_back(CardData.from_dict(db.cards["Pray"]))
	fightUI.update_ui_values()

