extends Control
class_name PauseScreen

@onready var Settings : Panel = $Settings
@onready var PauseMenu : Panel = $Panel
@onready var sfxSlider : HSlider = $Settings/TabContainer/Audio/GridContainer/SFXSlider
@onready var musicSlider : HSlider = $Settings/TabContainer/Audio/GridContainer/MusicSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("ui_escape"):
		if get_tree().paused:
			db.unpause()

func load_settings() -> void:
	sfxSlider.value = db.settingsData.sfxVolume
	musicSlider.value = db.settingsData.musicVolume
	

func apply_settings() -> void:
	db.settingsData.musicVolume = musicSlider.value
	db.settingsData.sfxVolume = sfxSlider.value
	db.apply_settings()
	db.settingsData.save_settings()

func _on_unpause_pressed() -> void:
	if get_tree().paused:
		db.unpause()


func _on_setings_back_pressed() -> void:
	Settings.visible = false
	PauseMenu.visible = true


func _on_settings_pressed() -> void:
	Settings.visible = true
	PauseMenu.visible = false


func _on_settings_apply() -> void:
	apply_settings()
	Settings.visible = false
	PauseMenu.visible = true
