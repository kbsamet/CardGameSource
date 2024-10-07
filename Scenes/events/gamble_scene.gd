extends Control
class_name GambleScene
var trialScene : PackedScene = preload("res://Scenes/events/Trial.tscn")
var trialDeckCardScene : PackedScene = preload("res://Scenes/events/TrialDeckCard.tscn")
var rewardCardScene : PackedScene = preload("res://Scenes/ui/RewardCard.tscn")
var chooseRewardScene : PackedScene = load("res://Scenes/screens/RewardSelectScreen.tscn")
var chooseCardScene : PackedScene = preload("res://Scenes/ui/ChooseCardReward.tscn")
var chooseRelicreward : PackedScene = preload("res://Scenes/ui/ChooseRelicreward.tscn")

@onready var trialContainer : HBoxContainer = $HBoxContainer
var into_dialogue : DialogueResource = load("res://Dialogues/Gambler.dialogue")
var in_dialogue : bool = false

var selected_trial : TrialData
var cards : Array[CardData] = []
var flipped_card_count :int = 0

var wager : String
var chosen_lost_card : CardData
var chosen_lost_relic : RelicData


func _ready() -> void:
	var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"start_intro")
	balloon.dialogue_ended.connect(_intro_dialogue_ended)
	balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
	balloon.check_flip_response()
	in_dialogue = true

func _intro_dialogue_ended() -> void:
	var trialsCopy : Array[TrialData] = db.trials.duplicate()
	for i in range(3):
		var trial : TrialData = trialsCopy.pick_random()
		trialsCopy.erase(trial)
		var new_trial : TrialScene = trialScene.instantiate()
		trialContainer.add_child(new_trial)
		new_trial.set_data(trial,i)
		new_trial.trial_chosen.connect(_trial_chosen)

func _trial_chosen(id:int) -> void:
	var selected_trial_node : TrialScene = trialContainer.get_child(id)
	selected_trial = selected_trial_node.trialData
	for n in trialContainer.get_children():
		trialContainer.remove_child(n)
	var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"deal_cards")
	balloon.dialogue_ended.connect(deal_cards)
	balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
	balloon.check_flip_response()
	in_dialogue = true

func deal_cards() -> void:
	
	var cards_copy : Array[CardData] = db.player.deck.duplicate(true)
	cards_copy.append(db.player.discardPile.duplicate(true))
	for i in range(3):
		var card_data : CardData = cards_copy.pick_random()
		cards.push_back(card_data)
		var trialDeckCard : TrialDeckCardScene = trialDeckCardScene.instantiate()
		trialContainer.add_child(trialDeckCard)
		trialDeckCard.set_data(card_data,i)
		trialDeckCard.card_flipped.connect(_card_flipped)
		cards_copy.erase(card_data)
	trialContainer.scale = Vector2(1,1)
	trialContainer.add_theme_constant_override("separation", 250)

func _card_flipped(id:int) -> void:
	flipped_card_count += 1
	if flipped_card_count == 3:
		await get_tree().create_timer(1.0).timeout
		for n in trialContainer.get_children():
			trialContainer.remove_child(n)
		var won : bool = check_win()
		if won:
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"win")
			balloon.dialogue_ended.connect(on_win)
			balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
			balloon.check_flip_response()
		else:
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"lost")
			balloon.dialogue_ended.connect(on_lost)
			balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
			balloon.check_flip_response()

func on_win() -> void:
	match wager:
		"gold":
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"won_gold")
			balloon.dialogue_ended.connect(leave)
			balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
			balloon.check_flip_response()
			db.player.gold *= 2
			db.player_state_changed.emit()
		"card":
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"won_card")
			balloon.dialogue_ended.connect(won_card)
			balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
			balloon.check_flip_response()
		"relic":
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"won_relic")
			balloon.dialogue_ended.connect(won_relic)
			balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
			balloon.check_flip_response()
		"health":
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"won_health")
			balloon.dialogue_ended.connect(leave)
			balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
			balloon.check_flip_response()
			db.player.heal_player(10)

func on_lost() -> void:
	match wager:
		"gold":
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"lost_gold")
			balloon.dialogue_ended.connect(leave)
			balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
			balloon.check_flip_response()
			db.player.gold = 0
			db.player_state_changed.emit()
		"card":
			var rare_cards : Array[CardData] = db.player.deck.filter(func(card:CardData) -> bool : return card.is_rare)
			if !rare_cards.is_empty():
				chosen_lost_card = rare_cards.pick_random()
			else:
				chosen_lost_card = db.player.deck.pick_random()
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"lost_card")
			balloon.dialogue_ended.connect(lose_card)
			balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
			balloon.check_flip_response()
		"relic":
			chosen_lost_relic = db.player.relics.pick_random()
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"lost_relic")
			balloon.dialogue_ended.connect(lose_relic)
			balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
			balloon.check_flip_response()
		"health":
			var balloon : Node = DialogueManager.show_dialogue_balloon(self,into_dialogue,"lost_health")
			balloon.dialogue_ended.connect(leave)
			balloon.get_child(0).global_position = Vector2(get_viewport_rect().size.x / 2 - balloon.get_child(0).get_child(0).size.x /2,50)
			balloon.check_flip_response()
			db.player.damage_player(10)
		
func show_lost_card() -> void:
	trialContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	var card_scene : RewardCardScene = rewardCardScene.instantiate()
	trialContainer.add_child(card_scene)
	card_scene.set_data(chosen_lost_card,0)
func show_lost_relic() -> void:
	trialContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	var relic : Sprite2D = Sprite2D.new()
	relic.scale = Vector2(5,5)
	var control :Control = Control.new()
	relic.texture = load("res://Sprites/ui/relics/"+chosen_lost_relic._name+".png")
	trialContainer.add_child(control)
	control.add_child(relic)

func lose_card() -> void:
	db.player.deck.erase(chosen_lost_card)
	db.player.deck_size -= 1
	db.player_state_changed.emit()
	leave()
func lose_relic() -> void:
	db.player.remove_relic(chosen_lost_relic._name)
	db.player_state_changed.emit()
	leave()
	
func won_relic() -> void:
	var chooseRelicInstance : ChooseRelicRewardScene = chooseRelicreward.instantiate()
	chooseRelicInstance.removeLabel = true
	$CanvasLayer.add_child(chooseRelicInstance)
	chooseRelicInstance.scale = Vector2(0.85,0.85)
	chooseRelicInstance.relic_chosen.connect(leave)
func won_card() -> void:
	var chooseCardInstance : ChooseCardScene = chooseCardScene.instantiate()
	chooseCardInstance.disable_button_and_text = true
	chooseCardInstance.rare_only = true
	$CanvasLayer.add_child(chooseCardInstance)
	chooseCardInstance.scale = Vector2(0.85,0.85)
	chooseCardInstance.card_chosen.connect(leave)
func leave() -> void:
	get_tree().change_scene_to_packed(chooseRewardScene)

func check_win() -> bool:
	match selected_trial._name:
		"Might":
			var sum : int = 0
			for card in cards:
				for effect in card.effects:
					if effect.effect == db.CardEffect.Damage or effect.effect == db.CardEffect.DamageAll:
						sum += effect.amount
			return sum > 9
		"Action":
			var sum : int = 0
			for card in cards:
				if card.type == db.CardType.Action:
					sum += 1
			return sum > 1
		"Reaction":
			var sum : int = 0
			for card in cards:
				if card.type == db.CardType.Reaction:
					sum += 1
			return sum > 1
		"Neutrality":
			var sum : int = 0
			for card in cards:
				if card.type == db.CardType.Neutral:
					sum += 1
			return sum > 0
		"Defense":
			var sum : int = 0
			for card in cards:
				for effect in card.effects:
					if effect.effect == db.CardEffect.Block:
						sum += effect.amount
			return sum > 5
	return false
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		for n in get_children():
			if n is DialogueBalloon:
				n._on_balloon_gui_input(event)
