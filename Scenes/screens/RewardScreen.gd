extends Control
class_name RewardScreen
var reward_data : RewardData
var rng  = RandomNumberGenerator.new()
@onready var reward = $Reward/RewardSprite
@onready var rewardText = $Reward/RewardText
var select_reward_screen = preload("res://Scenes/screens/RewardSelectScreen.tscn")
var outline_material = preload("res://Shaders/outline.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	reward.texture = load("res://Sprites/ui/rewardIcons/"+reward_data.reward+".png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_reward_mouse_entered():
	reward.material = outline_material


func _on_reward_mouse_exited():
	reward.material = null


func _on_reward_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			var amount = 0
			if TYPE_STRING == typeof(reward_data.amount):
				var boundries = reward_data.amount.split("-")
				assert(boundries.size() == 2, "Boundry not set properly on reward " + reward_data.reward)
				amount = rng.randi_range(int(boundries[0]),int(boundries[1]))
			else:
				amount = reward_data.amount
			db.player.add_player_items(reward_data.reward,amount)
			rewardText.text = "Gained " + str(amount) + " " + reward_data.reward
			reward.visible = false
			await get_tree().create_timer(1.0).timeout 
			get_tree().change_scene_to_packed(select_reward_screen)
