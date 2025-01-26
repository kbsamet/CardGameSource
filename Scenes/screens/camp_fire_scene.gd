extends Control

@export var noise : NoiseTexture2D
# Flickering parameters
@export var flicker_intensity: float = 0.2  # How much the light energy varies
@export var flicker_speed: float = 5.0  # Speed of flickering
@export var base_energy: float = 1.0  # Base light energy
@export var base_scale: float = 1.0  # Base light scale

var _time: float = 0.0

func _process(delta: float) -> void:
	flicker_light(delta)
func _ready() -> void:
	$AnimatedSprite2D.play("default")

func _on_button_2_pressed() -> void:
	db.player.heal_player(db.player.max_health / 2)
	if db.current_room % 6 == 0:
		get_tree().change_scene_to_packed(load("res://Scenes/screens/TavernOutsideScreen.tscn"))
		return
	get_tree().change_scene_to_packed(load("res://Scenes/screens/RewardSelectScreen.tscn"))
	

func _on_button_3_pressed() -> void:
	db.player.add_player_status_effect("trained",1)
	if db.current_room % 6 == 0:
		get_tree().change_scene_to_packed(load("res://Scenes/screens/TavernOutsideScreen.tscn"))
		return
	get_tree().change_scene_to_packed(load("res://Scenes/screens/RewardSelectScreen.tscn"))

func flicker_light(delta : float) -> void:
	$fireLight.position = Vector2(957,910)
	_time += delta * flicker_speed
	
	var sampled_noise : float = noise.noise.get_noise_1d(_time)
	sampled_noise = abs(sampled_noise)
	# Apply flickering to light
	$fireLight.energy = sampled_noise + base_energy

	# Optional: Add subtle color variation for more realism
	var color_variation : Color = Color(
		1.0, 
		0.8 + sin(_time) * 0.2,  # Slight red/orange variation 
		0.6 + cos(_time) * 0.1, 
		1.0
	)
	$fireLight.color = color_variation
