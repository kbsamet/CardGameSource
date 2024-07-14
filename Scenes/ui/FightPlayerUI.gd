extends Control
class_name PlayerUI

@onready var endTurnButton = $Container/EndTurnButton
@onready var endTurnButtonLabel = $Container/EndTurnButton/EndTurnlabel
@onready var deckCountLabel = $Deck/DeckCountLabel
@onready var discardPile = $DiscardPile
@onready var discardPileLabel = $DiscardPile/DiscardPileCountLabel

signal end_turn_clicked

var action_button_texture = preload("res://Sprites/ui/end_action.png")
var reaction_button_texture = preload("res://Sprites/ui/end_reaction.png")
var disabled_material = preload("res://Shaders/gray_tint.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	db.turn_changed.connect(turn_changed)
	update_ui_values()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_ui_values():
	if !is_inside_tree():
		return
	deckCountLabel.text = str(db.player.deck.size()) + " / " + str(db.player.deck_size )
	discardPileLabel.text = str(db.player.discardPile.size()) + " / " + str(db.player.deck_size )
	

func turn_changed(new_turn):
	match new_turn:
		db.Turn.PlayerAction:
			endTurnButton.texture = action_button_texture
			endTurnButtonLabel.text = "End Action"
			endTurnButton.material = null
		db.Turn.PlayerReaction:
			endTurnButton.texture = reaction_button_texture
			endTurnButtonLabel.text = "End Reaction"
			endTurnButton.material = null
		_:
			endTurnButton.texture = action_button_texture
			endTurnButton.material = disabled_material
func _on_button_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			end_turn_clicked.emit()
			
