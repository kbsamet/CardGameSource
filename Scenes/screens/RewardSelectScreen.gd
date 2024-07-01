extends Control

#1.435

@onready var door1 = $bg/DoorControl/Door1
@onready var door2 = $bg/Door2Control/Door2
@onready var reward1Icon = $bg/Reward1Icon
@onready var reward2Icon = $bg/Reward2Icon
@onready var reward1Label = $bg/Reward1Label
@onready var reward2Label = $bg/Reward2Label

var outline_material = preload("res://Shaders/outline.tres").duplicate(true)
const battle_controller = preload("res://Scenes/BattleController.tscn")
var selected_reward1 : RewardData
var selected_reward2 : RewardData
# Called when the node enters the scene tree for the first time.
func _ready():
	var selected_reward1_data = db.rewards.pick_random() as Dictionary
	var selected_reward2_data = db.rewards.pick_random() as Dictionary
	while selected_reward2_data == selected_reward1_data:
		selected_reward2_data = db.rewards.pick_random() as Dictionary
	selected_reward1 = RewardData.fromDict(selected_reward1_data)
	selected_reward2 = RewardData.fromDict(selected_reward2_data)
	
	reward1Icon.texture = load("res://Sprites/ui/rewardIcons/"+selected_reward1.reward+".png")
	reward2Icon.texture = load("res://Sprites/ui/rewardIcons/"+selected_reward2.reward+".png")
	reward1Label.text = selected_reward1.tooltip
	reward2Label.text = selected_reward2.tooltip
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_door1_mouse_entered():
	door1.material = outline_material


func _on_door1_mouse_exited():
	door1.material = null


func _on_door2_mouse_entered():
	door2.material = outline_material


func _on_door2l_mouse_exited():
	door2.material = null


func _on_doo1_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			var battle_controller_scene = battle_controller.instantiate() as BattleController
			battle_controller_scene.reward = selected_reward1
			get_tree().root.add_child(battle_controller_scene)
			get_tree().current_scene = battle_controller_scene
			queue_free()


func _on_door2_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			var battle_controller_scene = battle_controller.instantiate() as BattleController
			battle_controller_scene.reward = selected_reward2
			get_tree().root.add_child(battle_controller_scene)
			get_tree().current_scene = battle_controller_scene
			queue_free()
