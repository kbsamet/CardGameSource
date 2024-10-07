extends Control

var abilitySelectScreen : PackedScene = preload("res://Scenes/screens/AbilitySelectScreen.tscn")
@onready var levelLabel : Label = $VBoxContainer/LevelLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var minutes : int = db.run_time / 60
	var seconds : int= fmod(db.run_time, 60)
	var milliseconds : int = fmod(db.run_time, 1) * 100
	var time_string : String = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	levelLabel.text = "You made it to 1-"+str(db.current_room)+"\nYour time was: "+time_string

func _on_button_pressed() -> void:
	db.clickPlayer.play()
	db.reset_player()
	db.run_time = 0
	get_tree().change_scene_to_packed(abilitySelectScreen)
