extends Control

@export var chooseRewardScene = preload("res://Scenes/screens/RewardSelectScreen.tscn")
@onready var levelLabel = $VBoxContainer/LevelLabel
# Called when the node enters the scene tree for the first time.
func _ready():
	levelLabel.text = "You made it to 1-"+str(db.current_room)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	db.reset_player()
	get_tree().change_scene_to_packed(chooseRewardScene)
