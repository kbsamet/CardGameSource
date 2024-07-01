extends Resource
class_name RewardData

var reward : String
var amount : Variant
var tooltip : String

static func fromDict(reward_data : Dictionary):
	var new_reward : RewardData = RewardData.new()
	new_reward.reward = reward_data["reward"]
	new_reward.amount = reward_data["amount"]
	new_reward.tooltip = reward_data["tooltip"]
	return new_reward
