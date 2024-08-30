extends Control
class_name BattleController
@onready var hand : Hand  = $Control/Hand
@onready var enemyController : EnemyController = $Control/EnemyController
@onready var fightUI : PlayerUI= $Control/FightPlayerUI
@onready var hitSound : AudioStreamPlayer = $hitSound
@onready var screenAnimation :AnimationPlayer = $AnimationPlayer
@onready var statusEffectRect :ColorRect = $StatusEffectEffects

var enemyScene : PackedScene = preload("res://Scenes/enemies/Enemy.tscn")
var rewardScene : PackedScene= preload("res://Scenes/screens/RewardScreen.tscn")
var reward : RewardData
var card_selected : bool = false
var is_player_hit : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if db.player.deck.is_empty() && db.player.discardPile.is_empty():
		create_deck()
	db.player.start_fight_effects()
	db.screen_effect.connect(_on_screen_effect)
	db.player_status_effect_changed.connect(_on_player_status_effect)
	hand.selected_card_state_changed.connect(_on_card_select_state_changed)
	hand.play_card.connect(_use_card)
	enemyController._on_card_used.connect(_use_card)
	enemyController.enemy_turn_done.connect(_enemy_turn_done)
	enemyController.enemy_action_done.connect(_enemy_action_done)
	enemyController.hovered_enemy_changed.connect(_hovered_enemy_changed)
	enemyController.enemies_empty.connect(_fight_over)
	fightUI.end_turn_clicked.connect(_end_turn_clicked)
	hand.discardPosition = fightUI.discardPile.global_position
	hand.deckPosition = fightUI.deck.global_position
	hand.deal_hand()
	spawn_enemies()
	pass # Replace with function body.

func _on_player_status_effect() -> void:
	statusEffectRect.material.set_shader_parameter("block_effect","block" in db.player.status_effects)
	statusEffectRect.material.set_shader_parameter("overcharged_effect", "overcharged" in db.player.status_effects)

	if "dazed" in db.player.status_effects:
		$CanvasModulate.color = Color("7a7d82")
		
	else:
		$CanvasModulate.color = Color("a1b0c5")

func _on_screen_effect(effect : String) -> void:
	if effect == "damaged":
		is_player_hit = true
	if screenAnimation.is_playing() and screenAnimation.current_animation == effect:
		return
	screenAnimation.stop()
	screenAnimation.play(effect)

func _on_card_select_state_changed(newstate : bool) -> void:
	card_selected = newstate
	enemyController.set_card_selected(newstate)

	
func spawn_enemy(enemy_name : String) -> EnemyNode:
	var new_enemy : EnemyNode = enemyScene.instantiate() 
	new_enemy.enemy_data = db.get_enemy(enemy_name)
	enemyController.add_enemy(new_enemy)
	return new_enemy

func spawn_boss(boss_name : String) -> Node2D:
	var new_enemy : Node2D = load("res://Scenes/enemies/minibosses/"+boss_name+"Scene.tscn").duplicate(true).instantiate() 
	enemyController.add_boss(new_enemy)
	return new_enemy
	
func spawn_enemies() -> void:
	if db.current_room == 6:
		var wolf : Node2D = spawn_boss("GrayWolf")
		spawn_enemy("Hyena")
		spawn_enemy("Hyena")
		fightUI.set_boss_data(wolf.enemy.enemy_data)
		wolf.boss_state_changed.connect(fightUI.update_health_bar_ui)
		return
	if db.current_room == 12:
		var vampire : Node2D = spawn_boss("Vampire")
		fightUI.set_boss_data(vampire.enemy.enemy_data)
		vampire.boss_state_changed.connect(fightUI.update_health_bar_ui)
		vampire.boss_phase_changed.connect(boss_phase_changed)
		return
	var diff_cap : int = floor(2 + (db.current_room*1.1))
	var current_difficulty : int = 0
	var enemies : Dictionary = {}
	while current_difficulty < diff_cap:
		var new_enemy : EnemyData = db.enemies.pick_random() as EnemyData
		if new_enemy.difficulty > diff_cap * 3/4:
			continue
		if new_enemy.difficulty + current_difficulty > diff_cap:
				continue
		if new_enemy._name in enemies:
			if enemies[new_enemy._name] > 1:
				current_difficulty -= new_enemy.difficulty * enemies[new_enemy._name]
				enemies.erase(new_enemy._name)
				continue
			enemies[new_enemy._name] += 1
			current_difficulty += new_enemy.difficulty
		else:
			enemies[new_enemy._name] = 1
			current_difficulty += new_enemy.difficulty
	print("diff cap : " +str(diff_cap) + "\ncurrent difficulty: " + str(current_difficulty) )
	for key : String in enemies.keys():
		for value : int in enemies[key]:
			spawn_enemy(key)
	#var room_pool_key = "1-0" if db.current_room < 5 else "1-1"
	#var room = db.fight_rooms[room_pool_key].pick_random() as Dictionary
	#for key in room.keys():
		#for value in room[key]:
			#spawn_enemy(key)

func boss_phase_changed(new_data : EnemyData) -> void:
	fightUI.set_boss_data(new_data)
	fightUI.update_health_bar_ui()

func _use_card(enemy_id : int) -> void:
	if "blind" in db.player.status_effects:
		enemy_id = enemyController.enemies.keys().pick_random()
	var card_id : int = hand.selected_card
	if card_id == -1 || db.current_turn == db.Turn.EnemyAction || db.current_turn == db.Turn.EnemyReaction:
		return
	var selected_card : CardData = hand.cards[card_id].card_data
	if "blind" not in db.player.status_effects && selected_card.targeted && enemyController.attacking_enemy_id != -1 && enemyController.attacking_enemy_id != enemy_id:
		return
	var card_effects : Array[CardEffectData] =  selected_card.effects
	if (selected_card.type == db.CardType.Action && db.player.ap < selected_card.cost) || (selected_card.type == db.CardType.Reaction && db.player.rp < selected_card.cost) :
		return
	if (selected_card.type == db.CardType.Action && db.current_turn == db.Turn.PlayerReaction) || (selected_card.type == db.CardType.Reaction && db.current_turn == db.Turn.PlayerAction):
		return
	for effect in card_effects:
		if effect.next_turn:
			db.player.add_effect_next_turn(effect)
		else:
			match effect.effect:
				db.CardEffect.Damage:
					var base : int = effect.amount
					hitSound.play()
					enemyController.enemies[enemy_id].damage(calculate_damage(base,enemyController.enemies[enemy_id].enemy_data))
					if "inflict_bleed_with_attack" in db.player.status_effects:
						enemyController.enemies[enemy_id].add_status_effect("bleed", db.player.status_effects["inflict_bleed_with_attack"].amount)
				db.CardEffect.ShieldSlam:
					var base : int = 0 if "block" not in db.player.status_effects else db.player.status_effects["block"].amount
					hitSound.play()
					enemyController.enemies[enemy_id].damage(calculate_damage(base,enemyController.enemies[enemy_id].enemy_data))
				db.CardEffect.Riposte:
					var base : int = 0 if enemyController.enemies[enemy_id].selected_attack != null else effect.amount
					hitSound.play()
					enemyController.enemies[enemy_id].damage(calculate_damage(base, enemyController.enemies[enemy_id].enemy_data))
				db.CardEffect.Block:
					if "block" in db.player.status_effects:
						db.player.change_player_status_effect("block", db.player.status_effects.block.amount + effect.amount)
					else:
						db.player.change_player_status_effect("block", effect.amount)
				db.CardEffect.Daze:
					if enemy_id in enemyController.enemies:
						enemyController.enemies[enemy_id].add_status_effect("dazed", 1)
				db.CardEffect.Bleed:
					if enemy_id in enemyController.enemies:
						enemyController.enemies[enemy_id].add_status_effect("bleed", effect.amount)
				db.CardEffect.Heal:
					db.player.heal_player(effect.amount)
				db.CardEffect.Dodge:
					db.player.add_player_status_effect("dodge",effect.amount,true)
				db.CardEffect.DamageAll:
					for enemy : EnemyNode in enemyController.enemies.values():
						enemy.damage(calculate_damage(effect.amount,enemy.enemy_data))
						if "inflict_bleed_with_attack" in db.player.status_effects:
							enemy.add_status_effect("bleed", db.player.status_effects["inflict_bleed_with_attack"].amount)
				db.CardEffect.ConvertAllAp:
					db.player.rp += db.player.ap
					db.player.ap = 0
					db.player_state_changed.emit()
				db.CardEffect.ConvertAllRp:
					db.player.ap += db.player.rp
					db.player.rp = 0
					db.player_state_changed.emit()
				db.CardEffect.Crushing:
					db.player.add_player_status_effect("crushing",effect.amount,true)
				db.CardEffect.Draw:
					for i in range(effect.amount):
						hand.draw_card()
				db.CardEffect.Empower:
					db.player.add_player_status_effect("empowered",effect.amount,true)
				db.CardEffect.DiscardRandom:
					var hand_copy : Array = hand.cards.keys().duplicate()
					hand_copy.erase(card_id)
					hand.discard(hand_copy.pick_random())
				db.CardEffect.SwapActionReaction:
					db.player.swap_points()
				db.CardEffect.GainAp:
					db.player.ap += effect.amount
					db.player_state_changed.emit()
				db.CardEffect.GainRp:
					db.player.rp += effect.amount
					db.player_state_changed.emit()
				db.CardEffect.NoManaNextTurn:
					db.player.add_player_status_effect("overcharged",effect.amount)
				db.CardEffect.DoubleDamageTurn:
					db.player.add_player_status_effect("doubledamage",effect.amount,true)
				db.CardEffect.BleedAll:
					for enemy : EnemyNode in enemyController.enemies.values():
						enemy.add_status_effect("bleed", effect.amount)
				db.CardEffect.BarbedArmor:
					db.player.add_player_status_effect("barbedshield",effect.amount,true)
				db.CardEffect.GainApOnKill:
					if enemy_id not in enemyController.enemies or enemyController.enemies[enemy_id].enemy_data.health <= 0:
						db.player.ap += effect.amount
						db.player_state_changed.emit()
				db.CardEffect.DamageIfEnemyBleeding:
					if enemyController.enemies[enemy_id].enemy_data.get_status_effect("bleed") != -1:
						enemyController.enemies[enemy_id].damage(calculate_damage(effect.amount,enemyController.enemies[enemy_id].enemy_data))
					
	if db.current_turn == db.Turn.PlayerAction:
		db.player.ap = db.player.ap - selected_card.cost
		db.player_state_changed.emit()
	elif db.current_turn == db.Turn.PlayerReaction:
		db.player.rp = db.player.rp - selected_card.cost
		db.player_state_changed.emit()
	hand.discard(card_id)

func calculate_damage(base:int , enemy: EnemyData) -> int:
	var damage_amount : int = base
	if "empowered" in db.player.status_effects:
		damage_amount += db.player.status_effects["empowered"].amount
	if "crippled" in db.player.status_effects:
		damage_amount = max(0,damage_amount - db.player.status_effects["crippled"].amount)
	if "crushing" in db.player.status_effects && enemy.get_status_effect("dazed") != -1:
		damage_amount *= 2
	if "doubledamage" in db.player.status_effects:
		damage_amount *= 2
	if "empowered_overcharged" in db.player.status_effects and "overcharged" in db.player.status_effects:
		damage_amount *= 2
	return damage_amount
func _end_turn_clicked() ->void:
	for enemy : EnemyNode in enemyController.enemies.values():
		enemy = enemy as EnemyNode
		if enemy.animationPlayer.is_playing():
			return
		if enemy.death_animation_playing:
			return
	if db.current_turn == db.Turn.EnemyAction || db.current_turn == db.Turn.EnemyReaction:
		return
	if hand.selected_card != -1:
		return
		
	if db.current_turn == db.Turn.PlayerAction:
		if "overcharged" in db.player.status_effects:
			db.player.rp = 0
			db.player.add_player_status_effect("overcharged",-1)
			db.player_state_changed.emit()
		db.set_turn(db.Turn.EnemyAction)
		enemyController.start_turn()
	else:
		db.set_turn(db.Turn.EnemyAction)
		enemyController.end_enemy_attack()

func _enemy_turn_done() -> void:
	var carryover : bool =  "mana_carry_over" in db.player.status_effects
	var carry_ap : bool = db.player.ap > 0
	var carry_rp : bool = db.player.rp > 0 
	
	db.player.ap = db.player.max_ap
	db.player.rp = db.player.max_rp
	if carryover:
		if carry_ap:
			db.player.ap += 1
		if carry_rp:
			db.player.rp += 1
	db.player_state_changed.emit()
	db.player.end_turn_process_player_status_effects()
	db.check_game_over()
	db.set_turn(db.Turn.PlayerAction)
	enemyController.attacking_enemy_id = -1
	hand.discard_all()
	await hand.deal_hand()
	if "blind" in db.player.status_effects:
		db.player.add_player_status_effect("blind",-1)
	if "burn" in db.player.status_effects:
		hand.discard(hand.cards.keys().pick_random())
		db.player.add_player_status_effect("burn",-1)
	if "crushing" in db.player.status_effects:
		db.player.add_player_status_effect("crushing",-1)
	if "crippled" in db.player.status_effects:
		db.player.add_player_status_effect("crippled",-1)
	if "drainAp" in db.player.status_effects:
		db.player.add_player_status_effect("drainAp",-1)
	if "drainRp" in db.player.status_effects:
		db.player.add_player_status_effect("drainRp",-1)
	if "doubledamage" in db.player.status_effects:
		db.player.add_player_status_effect("doubledamage",-1)
	if "barbedshield" in db.player.status_effects:
		db.player.add_player_status_effect("barbedshield",-1)
	if "empowered" in db.player.status_effects and db.player.status_effects["empowered"].amount > 0:
		db.player.add_player_status_effect("empowered",-1)
	if "dazed" in db.player.status_effects:
		db.player.add_player_status_effect("dazed", -1)
		db.set_turn(db.Turn.EnemyAction)
		enemyController.start_turn()
	if "overcharged" in db.player.status_effects:
		db.player.ap = 0
		db.player.add_player_status_effect("overcharged",-1)
		db.player_state_changed.emit()
		
func _fight_over() -> void:
	if "heal_if_not_hit" in db.player.status_effects and !is_player_hit:
		db.player.heal_player(db.player.status_effects["heal_if_not_hit"].amount)
	db.player.ap = db.player.max_ap
	db.player.rp = db.player.max_rp
	db.player_state_changed.emit()
	db.player.end_turn_process_player_status_effects()
	db.check_game_over()
	db.set_turn(db.Turn.PlayerAction)
	db.player.gold += 5
	enemyController.attacking_enemy_id = -1
	db.player.end_fight_process_player_status_effects()
	hand.discard_all()
	var reward_scene : RewardScreen = rewardScene.instantiate() 
	reward_scene.reward_data = reward
	fightUI.remove_boss_data()
	db.increase_level()
	get_tree().root.add_child(reward_scene)
	get_tree().current_scene = reward_scene
	queue_free()

	
func _enemy_action_done(enemy_id : int) -> void:
	db.set_turn(db.Turn.PlayerReaction)

func _hovered_enemy_changed(enemy_id:int) -> void:
	if enemy_id == -1:
		hand.enemy_hovered(enemy_id,null)
	else:
		hand.enemy_hovered(enemy_id,enemyController.enemies[enemy_id].global_position)
	 
func create_deck() -> void:
	for i in range(4):
		db.player.deck.push_back(db.get_card("Strike"))
		db.player.deck.push_back(db.get_card("Block"))
	db.player.deck.push_back(db.get_card("Strike"))
	db.player.deck.push_back(db.get_card("Daze"))
	var dice : Array[RelicData] = db.relics.filter(func(relic : RelicData) -> bool : return relic._name == "Hourglass")
	#db.player.add_relic(dice[0])
	fightUI.update_ui_values()



func _on_animation_player_animation_finished(anim_name : String) -> void:
	$ColorRect.visible = false
