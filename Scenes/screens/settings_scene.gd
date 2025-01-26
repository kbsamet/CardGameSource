extends Control
class_name SettingsScreen

@onready var sfxSlider : HSlider = $Settings/TabContainer/Audio/GridContainer/SFXSlider
@onready var musicSlider : HSlider = $Settings/TabContainer/Audio/GridContainer/MusicSlider
signal back_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()


func load_settings() -> void:
	sfxSlider.value = db.settingsData.sfxVolume
	musicSlider.value = db.settingsData.musicVolume
	

func apply_settings() -> void:
	db.settingsData.musicVolume = musicSlider.value
	db.settingsData.sfxVolume = sfxSlider.value
	db.apply_settings()
	db.settingsData.save_settings()

func _on_confirm_pressed() -> void:
	db.clickPlayer.play()
	apply_settings()
	back_pressed.emit()


func _on_back_pressed() -> void:
	db.clickPlayer.play()
	back_pressed.emit()
