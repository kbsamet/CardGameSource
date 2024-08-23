extends Control

#1.435

@onready var door1 : Sprite2D = $bg/DoorControl/Door1
@onready var door2 : Sprite2D = $bg/Door2Control/Door2
@onready var reward1Icon : Sprite2D = $bg/Reward1Icon
@onready var reward2Icon : Sprite2D = $bg/Reward2Icon
@onready var reward1Label : Label = $bg/Reward1Label
@onready var reward2Label : Label = $bg/Reward2Label

var outline_material : ShaderMaterial = preload("res://Shaders/outline.tres").duplicate(true)
const battle_controller = preload("res://Scenes/BattleController.tscn")
var selected_reward1 : RewardData
var selected_reward2 : RewardData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var reward_pool : Array[RewardData] = []
	var rewards_dict : Array[Dictionary] = db.rewards
	if db.current_room % 5 == 0:
		rewards_dict = db.boss_rewards
	for reward_data in rewards_dict:
		var reward : RewardData = RewardData.fromDict(reward_data)
		for i in range(reward.multiplier):
			reward_pool.append(reward)
	selected_reward1 = reward_pool.pick_random() 
	selected_reward2 = reward_pool.pick_random() 
	while selected_reward2 == selected_reward1:
		selected_reward2 = reward_pool.pick_random()
	
	reward1Icon.texture = load("res://Sprites/ui/rewardIcons/"+selected_reward1.reward+".png")
	reward2Icon.texture = load("res://Sprites/ui/rewardIcons/"+selected_reward2.reward+".png")
	reward1Label.text = selected_reward1.tooltip
	reward2Label.text = selected_reward2.tooltip
	if rewards_dict == db.boss_rewards:
		reward1Label.modulate = Color("ffd240")
		reward2Label.modulate = Color("ffd240")
	

func _on_door1_mouse_entered() -> void:
	door1.material = outline_material


func _on_door1_mouse_exited() -> void:
	door1.material = null


func _on_door2_mouse_entered() -> void:
	door2.material = outline_material


func _on_door2l_mouse_exited() -> void:
	door2.material = null


func _on_doo1_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			var battle_controller_scene : BattleController = battle_controller.instantiate() 
			battle_controller_scene.reward = selected_reward1
			get_tree().root.add_child(battle_controller_scene)
			get_tree().current_scene = battle_controller_scene
			queue_free()


func _on_door2_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			var battle_controller_scene : BattleController = battle_controller.instantiate()
			battle_controller_scene.reward = selected_reward2
			get_tree().root.add_child(battle_controller_scene)
			get_tree().current_scene = battle_controller_scene
			queue_free()
