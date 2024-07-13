extends Control
class_name ChooseRelicRewardScene
signal relic_chosen

@onready var relicIcon = $Control/RelicIcon
@onready var relic2Icon = $Control/Relic2Icon
@onready var relic3Icon = $Control/Relic3Icon

var relics : Array[RelicData]
# Called when the node enters the scene tree for the first time.
func _ready():
	var relics_copy = db.relics.duplicate(true)
	relics_copy.erase("Strike")
	relics_copy.erase("Block")
	for i in range(3):
		var chosen_key = relics_copy.keys().pick_random()
		var relic_data = RelicData.from_dict(relics_copy[chosen_key])
		relics.push_back(relic_data)
		relics_copy.erase(chosen_key)
	relicIcon.set_data(relics[0])
	relic2Icon.set_data(relics[1])
	relic3Icon.set_data(relics[2])
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_relic_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			db.player.add_relic(relics[0])
			relic_chosen.emit()

func _on_relic2_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			db.player.add_relic(relics[1])
			relic_chosen.emit()


func _on_relic3_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			db.player.add_relic(relics[2])
			relic_chosen.emit()
