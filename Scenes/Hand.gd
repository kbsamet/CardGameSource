extends Container
class_name Hand

var cards : Dictionary = {}
var id_count : int = 0
var selected_card : int= -1
var dragged_card_id : int = -1
var selected_enemy_id : int = -1
var random :  = RandomNumberGenerator.new()
var discardPosition : Vector2
var deckPosition : Vector2
@onready var cardScene : PackedScene = preload("res://Scenes/Card.tscn")
@onready var flippedCardSprite : CompressedTexture2D = preload("res://Sprites/ui/deck.png")
@onready var arrow : CardDragArrow = $CardDragArrow
@onready var shufflePlayer : AudioStreamPlayer  = $shufflePlayer
@onready var dealPlayer : AudioStreamPlayer  = $dealPlayer


signal selected_card_state_changed(new_state : bool)
signal play_card(nil : Variant)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	if dragged_card_id != -1:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		arrow.set_data(cards[dragged_card_id].global_position,get_global_mouse_position(),false)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass



func turn_changed(new_turn : db.Turn) -> void:
	if selected_card != -1:
		cards[selected_card].set_selected(false)
		selected_card = -1
		
func _on_card_clicked(id : int) -> void:
	pass
	#if cards[id].disabled:
		#return
	#if selected_card == -1:
		#cards[id].set_selected(true)
		#selected_card = id
		#selected_card_state_changed.emit(true)
	#elif selected_card == id:
		#if !cards[selected_card].card_data.targeted:
			#play_card.emit(null)
			#return
		#
		#cards[selected_card].set_selected(false)
		#selected_card_state_changed.emit(false)
		#selected_card = -1
	#else:
		#cards[selected_card].set_selected(false)
		#cards[id].set_selected(true)
		#selected_card = id
		#selected_card_state_changed.emit(true)

func _on_card_hold(id : int) -> void:
	if id == -1:
		if dragged_card_id != -1:
			if !cards[dragged_card_id].card_data.targeted or "blind" in db.player.status_effects:
				if cards[dragged_card_id].position.y < -300:
					play_card.emit(-1)
				else:
					center_cards()
					create_tween().tween_property(cards[dragged_card_id],"position:y",0,0.3)

			elif selected_enemy_id != -1:
				play_card.emit(selected_enemy_id)
		if selected_card != -1:
			cards[selected_card].set_selected(false)
		selected_card_state_changed.emit(false)
		selected_card = -1
		arrow.make_visible(false)
	else:
		if !(id in cards) or cards[id].disabled or dragged_card_id != -1:
			return
		cards[id].set_selected(true)
		selected_card_state_changed.emit(true)
		selected_card = id
		if cards[id].card_data.targeted and !("blind" in db.player.status_effects):
			arrow.make_visible(true)
	dragged_card_id = id

func enemy_hovered(enemy_id : int,enemy_position: Variant) -> void:
	if enemy_id != -1 && dragged_card_id != -1 && cards[dragged_card_id].card_data.targeted && !("blind" in db.player.status_effects):
		#var animate = arrow.visible
		selected_enemy_id = enemy_id
		#arrow.visible = true
		#arrow.set_data(cards[dragged_card_id].global_position,get_global_mouse_position(),animate)
	else:
		selected_enemy_id = -1
		#arrow.visible = true

func center_cards() -> Variant:
	if cards.is_empty():
		return
	var card_sprite : Sprite2D = cards.values()[0].find_child("Sprite")
	var card_width : float = card_sprite.texture.get_size().x
	var card_count : int = cards.size()
	var card_keys : Array = cards.keys()
	var tween : Tween = create_tween().set_parallel()
	for i in range(card_keys.size()):
		# ortadaki kart 0 sol sağ +1 -1 diye gidiyo bunla sprite scale i çarpıyoruz
		tween.tween_property(cards[card_keys[i]],"position:x",(i - ((card_count - 1)/2.0)) * (card_width * (card_sprite.transform.get_scale().x) - 40),0.3)
	
	return tween.finished

func add_card(card : CardNode,tween : Tween,empty_hand : bool = false) -> Signal:
	card.on_hold_signal.connect(_on_card_hold)
	card.on_clicked_signal.connect(_on_card_clicked)
	cards[id_count] = card
	card.id = id_count
	id_count += 1
	add_child(card)
	card.global_position = deckPosition
	card.scale = Vector2(0.3,0.3)
	var i : int =  cards.size()-(db.player.hand_size / 2) if empty_hand else cards.size() - 1
	var card_sprite : Sprite2D = cards.values()[0].find_child("Sprite")
	var card_width : float = card_sprite.texture.get_size().x
	tween.tween_property(card,"position:x",(i - ((cards.size() - 1)/2.0)) * (card_width * (card_sprite.transform.get_scale().x) - 40),0.1)
	tween.parallel().tween_property(card,"position:y",0,0.1)
	tween.parallel().tween_property(card,"scale",Vector2(1,1),0.1)
	tween.tween_callback(func() -> void: dealPlayer.play())
	return tween.finished
	
func discard(id : int) -> void:
	db.player.discardPile.push_back(cards[id].card_data)
	if is_inside_tree():
		var tween : Tween = create_tween()
		var card : CardNode = cards[id]
		tween.tween_property(card,"position:y", card.position.y-200, 0.1)
		tween.tween_property(card,"global_position",discardPosition,0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.set_parallel(true)
		tween.tween_property(card,"scale", Vector2(0.1,0.1),0.3 ).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.set_parallel(false)
		tween.tween_callback(func() -> void: card_freed(card))
	else:
		card_freed(cards[id])
	cards.erase(id)
	center_cards()
	selected_card = -1

func card_freed(card : Node) -> void:
	remove_child(card)
	card.queue_free()
	
func discard_all() -> void:
	for card_id : int in cards.keys():
		discard(card_id)

func shuffle_discard_to_deck() -> Signal:
	shufflePlayer.play()
	for card in db.player.discardPile:
		db.player.deck.append(card.duplicate(true))
	
	db.player.discardPile = []
	db.player_state_changed.emit()
	var tween : Tween = create_tween()
	for i in range(db.player.discardPile.size()):
		var card_sprite : Sprite2D = Sprite2D.new()
		add_child(card_sprite)
		card_sprite.texture = flippedCardSprite
		card_sprite.global_position = discardPosition
		tween.tween_property(card_sprite,"global_position",deckPosition,0.1)
		tween.tween_callback(func() -> void: card_sprite.queue_free())
	return tween.finished
	
func draw_card() -> void:
	if db.player.deck.size() == 0:
		shuffle_discard_to_deck()
	var index : int = random.randi_range(0,db.player.deck.size() -1)
	var card : CardData = db.player.deck[index]
	var new_card : CardNode = cardScene.instantiate()
	new_card.card_data = card
	var tween : Tween = create_tween()
	add_card(new_card,tween)
	tween.tween_callback(center_cards)
	db.remove_from_deck(index)
	
func deal_hand() -> Signal:
	var tween : Tween= create_tween()
	while cards.size() < db.player.hand_size:
		if db.player.deck.size() == 0:
			shuffle_discard_to_deck()
		var index : int= random.randi_range(0,db.player.deck.size() -1)
		var card : CardData = db.player.deck[index]
		var new_card : CardNode = cardScene.instantiate()
		new_card.card_data = card
		add_card(new_card,tween,true)
		db.remove_from_deck(index)
	await tween.finished
	await center_cards()
	#if db.player.deck.size() < db.player.hand_size:
		#var difference = db.player.hand_size - db.player.deck.size()
		#for i in range(db.player.deck.size()):
			#var index = random.randi_range(0,db.player.deck.size() -1)
			#var card = db.player.deck[index]
			#var new_card = cardScene.instantiate()
			#new_card.card_data = card
			#add_card(new_card,tween,true)
			#db.remove_from_deck(index)
		#await tween.finished
		#await shuffle_discard_to_deck()
		#for i in range(difference):
			#var index = random.randi_range(0,db.player.deck.size() -1)
			#var card = db.player.deck[index]
			#var new_card = cardScene.instantiate()
			#new_card.card_data = card
			#add_card(new_card,tween,true)
			#db.remove_from_deck(index)
		#await tween.finished
		#await center_cards()
	#else:
		#while cards.size() < db.player.hand_size:
			#var index = random.randi_range(0,db.player.deck.size() -1)
			#var card = db.player.deck[index]
			#var new_card = cardScene.instantiate()
			#new_card.card_data = card
			#add_card(new_card,tween,true)
			#db.remove_from_deck(index)
		#await tween.finished
		#await center_cards()
	return tween.finished
