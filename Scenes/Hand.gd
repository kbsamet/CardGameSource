extends Container

var cards : Dictionary = {}
var id_count = 0
var selected_card = -1
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
	remove_child(cards[id])
	cards.erase(id)
	center_cards()
	selected_card = -1
