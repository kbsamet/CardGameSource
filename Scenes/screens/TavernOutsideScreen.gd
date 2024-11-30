extends Control

var tavernOutsideMusic : AudioStream = preload("res://Sounds/Music/tavern_outside.mp3")
var outline_material : ShaderMaterial = preload("res://Shaders/outline.tres")
var tavernScene : PackedScene = load("res://Scenes/screens/TavernScreen.tscn")
@onready var tavern : Sprite2D = $Control/Tavern

func _ready() -> void:
	if db.music.stream != tavernOutsideMusic:
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"),0, true)
		db.music.stop()
		db.music.stream = tavernOutsideMusic
		db.music.stream.loop = true
		db.music.play()

func _on_control_mouse_entered() -> void:
	tavern.material = outline_material


func _on_control_mouse_exited() -> void:
	tavern.material = null


func _on_control_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.setup_merchant_shop()
			AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"),0, false)
			get_tree().change_scene_to_packed(tavernScene)
