extends Control

@export var chooseRewardScene = preload("res://Scenes/screens/RewardSelectScreen.tscn")
@onready var levelLabel = $VBoxContainer/LevelLabel
# Called when the node enters the scene tree for the first time.
func _ready():
	var minutes = db.run_time / 60
	var seconds = fmod(db.run_time, 60)
	var milliseconds = fmod(db.run_time, 1) * 100
	var time_string = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	levelLabel.text = "You made it to 1-"+str(db.current_room)+"\nYour time was: "+time_string

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	db.clickPlayer.play()
	db.reset_player()
	db.run_time = 0
	get_tree().change_scene_to_packed(chooseRewardScene)
