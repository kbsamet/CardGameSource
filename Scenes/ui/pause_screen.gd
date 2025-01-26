extends Control
class_name PauseScreen

@onready var Settings : SettingsScreen = $SettingsScene
@onready var PauseMenu : Panel = $Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !db.run_started:
		$Panel/VBoxContainer/Button3.visible = false
	Settings.back_pressed.connect(_on_settings_back_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("ui_escape"):
		if get_tree().paused:
			db.unpause()


func _on_unpause_pressed() -> void:
	db.clickPlayer.play()
	if get_tree().paused:
		db.unpause()


func _on_setings_back_pressed() -> void:
	Settings.visible = false
	PauseMenu.visible = true
	db.clickPlayer.play()


func _on_settings_pressed() -> void:
	Settings.visible = true
	PauseMenu.visible = false
	db.clickPlayer.play()

func _on_settings_back_pressed() -> void:
	Settings.visible = false
	PauseMenu.visible = true


func _on_abandon_run_pressed() -> void:
	db.clickPlayer.play()
	if get_tree().paused:
		db.unpause()
		db.player_dead.emit()
		
