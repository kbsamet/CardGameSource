extends Container
class_name Hand

var cards : Dictionary = {}
var id_count = 0
var selected_card = -1
var random = RandomNumberGenerator.new()
@export var discardPosition : Vector2
@export var cardScene = preload("res://Scenes/Card.tscn")
signal selected_card_state_changed(new_state)
signal play_card(nil)
# Called when the node enters the scene tree for the first time.
func _ready():
	db.turn_changed.connect(turn_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_card(card : Node):
	card.on_clicked_signal.connect(_on_card_clicked)
	cards[id_count] = card
	card.id = id_count
	id_count += 1
	add_child(card)
	center_cards()

func center_cards():
	if cards.is_empty():
		return
	var card_sprite : Sprite2D = cards.values()[0].find_child("Sprite")
	var card_width = card_sprite.texture.get_size().x
	var card_count = cards.size()
	var card_keys = cards.keys()
	for i in range(card_keys.size()):
		# ortadaki kart 0 sol sağ +1 -1 diye gidiyo bunla sprite scale i çarpıyoruz
		cards[card_keys[i]].position.x = (i - ((card_count - 1)/2.0)) * (card_width * (card_sprite.transform.get_scale().x) + 10)

func turn_changed(new_turn):
	if selected_card != -1:
		cards[selected_card].set_selected(false)
		selected_card = -1
func _on_card_clicked(id):
	if cards[id].disabled:
		return
	if selected_card == -1:
		cards[id].set_selected(true)
		selected_card = id
		selected_card_state_changed.emit(true)
	elif selected_card == id:
		if !cards[selected_card].card_data.targeted:
			play_card.emit(null)
			return
		
		cards[selected_card].set_selected(false)
		selected_card_state_changed.emit(false)
		selected_card = -1
	else:
		cards[selected_card].set_selected(false)
		cards[id].set_selected(true)
		selected_card = id
		selected_card_state_changed.emit(true)

func discard(id):
	db.player.discardPile.push_back(cards[id].card_data)
	if is_inside_tree():
		var tween = create_tween()
		var card = cards[id]
		tween.tween_property(card,"position:y", card.position.y-200, 0.1)
		tween.tween_property(card,"global_position",discardPosition,0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.set_parallel(true)
		tween.tween_property(card,"scale", Vector2(0.1,0.1),0.3 ).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.set_parallel(false)
		tween.tween_callback(func() : card_freed(card))
	else:
		card_freed(cards[id])
	cards.erase(id)
	center_cards()
	selected_card = -1

func card_freed(card : Node):
	remove_child(card)
	card.queue_free()
	
func discard_all():
	for card_id in cards.keys():
		discard(card_id)

func deal_hand():
	while cards.size() < db.player.hand_size:
		if db.player.deck.size() == 0:
			db.shuffle_discard_to_deck()
		var index = random.randi_range(0,db.player.deck.size() -1)
		var card = db.player.deck[index]
		var new_card = cardScene.instantiate()
		new_card.card_data = card
		add_card(new_card)
		db.remove_from_deck(index)
