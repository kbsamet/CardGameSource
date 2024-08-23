extends Control
class_name RewardScreen
var reward_data : RewardData = RewardData.fromDict(db.rewards[1])
var rng  : RandomNumberGenerator = RandomNumberGenerator.new()
var reward_selected : bool = false
@onready var reward : Sprite2D = $Reward/RewardSprite
@onready var rewardText : Label = $Reward/RewardText
var outline_material : ShaderMaterial = preload("res://Shaders/outline.tres")
var choose_card_scene : PackedScene = preload("res://Scenes/ui/ChooseCardReward.tscn")
var choose_relic_scene : PackedScene = preload("res://Scenes/ui/ChooseRelicreward.tscn")
var tavern_scene : PackedScene = preload("res://Scenes/screens/TavernOutsideScreen.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if reward_data.reward == "choose_card" or reward_data.reward == "choose_rare_card" :
		reward.visible = false
		reward.queue_free()
		var card_scene : ChooseCardScene = choose_card_scene.instantiate()
		card_scene.rare_only = reward_data.reward == "choose_rare_card"
		card_scene.card_chosen.connect(_go_to_select_reward)
		add_child(card_scene)
	elif reward_data.reward == "choose_relic":
		reward.visible = false
		reward.queue_free()
		var relic_scene : ChooseRelicRewardScene = choose_relic_scene.instantiate() 
		relic_scene.relic_chosen.connect(_go_to_select_reward)
		add_child(relic_scene)
	elif reward_data.reward == "tavern":
		get_tree().change_scene_to_packed(tavern_scene)
	reward.texture = load("res://Sprites/ui/rewardIcons/"+reward_data.reward+".png")

func _go_to_select_reward() -> void:
	if db.current_room % 5 == 0:
		get_tree().change_scene_to_packed(tavern_scene)
		return
	get_tree().change_scene_to_packed(load("res://Scenes/screens/RewardSelectScreen.tscn"))

func _on_reward_mouse_entered() -> void:
	if reward != null:
		reward.material = outline_material


func _on_reward_mouse_exited() -> void:
	if reward != null:
		reward.material = null

func get_regular_reward(reward_name : String,reward_amount : Variant) -> void:
	var amount : int = 0
	reward_selected = true
	if TYPE_STRING == typeof(reward_amount):
		var boundries : PackedStringArray = reward_amount.split("-")
		assert(boundries.size() == 2, "Boundry not set properly on reward " + reward_name)
		amount = rng.randi_range(int(boundries[0]),int(boundries[1]))
	else:
		amount = reward_amount
	db.player.add_player_items(reward_name,amount)
	rewardText.text = "Gained " + str(amount) + " " + reward_name
	reward.visible = false
	await get_tree().create_timer(1.0).timeout 
	if db.current_room % 5 == 0:
		get_tree().change_scene_to_packed(tavern_scene)
		return
	get_tree().change_scene_to_packed(load("res://Scenes/screens/RewardSelectScreen.tscn"))

func get_chest_reward() -> void:
	reward_selected = true
	if db.player.keys == 0:
		rewardText.text = "You couldn't open the chest"
		reward.visible = false
		await get_tree().create_timer(1.0).timeout
		if db.current_room % 5 == 0:
			get_tree().change_scene_to_packed(tavern_scene)
			return
		get_tree().change_scene_to_packed(load("res://Scenes/screens/RewardSelectScreen.tscn"))
		return
	db.player.keys -= 1
	var reward_pool : Array[Dictionary] = []
	for reward in db.locked_chest_rewards:
		for m : int in reward.multiplier:
			reward_pool.append(reward.duplicate(true))
	
	var random_reward : Dictionary = reward_pool.pick_random()
	if random_reward.reward == "choose_rare_card":
		reward.visible = false
		reward.queue_free()
		var card_scene : ChooseCardScene = choose_card_scene.instantiate()
		card_scene.rare_only = true
		card_scene.card_chosen.connect(_go_to_select_reward)
		add_child(card_scene)
	elif random_reward.reward == "choose_relic":
		reward.visible = false
		reward.queue_free()
		var relic_scene : ChooseRelicRewardScene = choose_relic_scene.instantiate() as ChooseRelicRewardScene
		relic_scene.relic_chosen.connect(_go_to_select_reward)
		add_child(relic_scene)
	else:
		get_regular_reward(random_reward.reward, random_reward.amount)
		
func _on_reward_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() and !reward_selected:
			db.clickPlayer.play()
			if reward_data.reward == "locked_chest":
				get_chest_reward()
				return
			get_regular_reward(reward_data.reward,reward_data.amount)
