extends Control

@onready var clickPlayer : AudioStreamPlayer = $ClickPlayer
@onready var settingsScreen : SettingsScreen  = $SettingsScene
@onready var abilitySelectScreen : PackedScene = preload("res://Scenes/screens/AbilitySelectScreen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db.run_started = false
	settingsScreen.back_pressed.connect(_on_settings_back_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_run_pressed() -> void:
	db.clickPlayer.play()
	db.run_started = true
	get_tree().change_scene_to_packed(abilitySelectScreen)
	

func _on_settings_pressed() -> void:
	db.clickPlayer.play()
	settingsScreen.visible = true

func _on_settings_back_pressed() -> void:
	settingsScreen.visible = false

func _on_quit_pressed() -> void:
	db.clickPlayer.play()
	get_tree().quit()
