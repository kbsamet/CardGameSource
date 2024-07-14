extends Control
class_name RewardScreen
var reward_data : RewardData = RewardData.fromDict(db.rewards[2])
var rng  = RandomNumberGenerator.new()
@onready var reward = $Reward/RewardSprite
@onready var rewardText = $Reward/RewardText
var select_reward_screen = preload("res://Scenes/screens/RewardSelectScreen.tscn")
var outline_material = preload("res://Shaders/outline.tres")
var choose_card_scene = preload("res://Scenes/ui/ChooseCardReward.tscn")
var choose_relic_scene = preload("res://Scenes/ui/ChooseRelicreward.tscn")
var tavern_scene = preload("res://Scenes/screens/TavernScreen.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	if reward_data.reward == "choose_card":
		reward.visible = false
		reward.queue_free()
		var card_scene = choose_card_scene.instantiate()
		card_scene.card_chosen.connect(_go_to_select_reward)
		add_child(card_scene)
	elif reward_data.reward == "choose_relic":
		reward.visible = false
		reward.queue_free()
		var relic_scene = choose_relic_scene.instantiate() as ChooseRelicRewardScene
		relic_scene.relic_chosen.connect(_go_to_select_reward)
		add_child(relic_scene)
	reward.texture = load("res://Sprites/ui/rewardIcons/"+reward_data.reward+".png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _go_to_select_reward():
	get_tree().change_scene_to_packed(select_reward_screen)

func _on_reward_mouse_entered():
	reward.material = outline_material


func _on_reward_mouse_exited():
	reward.material = null

func get_regular_reward(reward_name,reward_amount):
	var amount = 0
	if TYPE_STRING == typeof(reward_amount):
		var boundries = reward_amount.split("-")
		assert(boundries.size() == 2, "Boundry not set properly on reward " + reward_name)
		amount = rng.randi_range(int(boundries[0]),int(boundries[1]))
	else:
		amount = reward_amount
	db.player.add_player_items(reward_name,amount)
	rewardText.text = "Gained " + str(amount) + " " + reward_name
	reward.visible = false
	await get_tree().create_timer(1.0).timeout 
	get_tree().change_scene_to_packed(select_reward_screen)

func get_chest_reward():
	if db.player.keys == 0:
		rewardText.text = "You couldn't open the chest"
		reward.visible = false
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_packed(select_reward_screen)
		return
	db.player.keys -= 1
	var random_reward = db.locked_chest_rewards.pick_random()
	if random_reward.reward == "choose_card":
		reward.visible = false
		reward.queue_free()
		var card_scene = choose_card_scene.instantiate()
		card_scene.card_chosen.connect(_go_to_select_reward)
		add_child(card_scene)
	elif random_reward.reward == "choose_relic":
		reward.visible = false
		reward.queue_free()
		var relic_scene = choose_relic_scene.instantiate() as ChooseRelicRewardScene
		relic_scene.relic_chosen.connect(_go_to_select_reward)
		add_child(relic_scene)
	else:
		get_regular_reward(random_reward.reward, random_reward.amount)
		
func _on_reward_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			if reward_data.reward == "locked_chest":
				get_chest_reward()
				return
			elif reward_data.reward == "tavern":
				get_tree().change_scene_to_packed(tavern_scene)
				return
			get_regular_reward(reward_data.reward,reward_data.amount)
