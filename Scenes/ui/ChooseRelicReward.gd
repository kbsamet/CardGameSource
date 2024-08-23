extends Control
class_name ChooseRelicRewardScene
signal relic_chosen

@onready var relicIcon : RelicIcon = $Control/RelicIcon
@onready var relic2Icon : RelicIcon = $Control/Relic2Icon
@onready var relic3Icon : RelicIcon = $Control/Relic3Icon

var relics : Array[RelicData]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var relics_copy : Array[RelicData] = db.relics.duplicate(true)
	for i in range(3):
		var chosen_index : int = randi_range(0,relics_copy.size()-1)
		var relic_data : RelicData = relics_copy[chosen_index]
		relics.push_back(relic_data)
		relics_copy.remove_at(chosen_index)
	relicIcon.set_data(relics[0])
	relic2Icon.set_data(relics[1])
	relic3Icon.set_data(relics[2])

func _on_relic_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			db.player.add_relic(relics[0])
			relic_chosen.emit()

func _on_relic2_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			db.player.add_relic(relics[1])
			relic_chosen.emit()


func _on_relic3_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			db.player.add_relic(relics[2])
			relic_chosen.emit()
