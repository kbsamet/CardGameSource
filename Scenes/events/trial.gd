extends Control

class_name TrialScene
@onready var nameLabel : Label = $Control/NameLabel
@onready var descriptionLabel : RichTextLabel = $Control/DescriptionContainer/DescriptionLabel
@onready var sprite :Sprite2D = $Sprite

signal trial_chosen(id:int)
var trialData : TrialData 
var id : int
func set_data(trial_data : TrialData,_id : int) -> void:
	trialData = trial_data
	nameLabel.text = trialData._name
	descriptionLabel.text = "[center]"+trialData.description
	sprite.texture = load("res://Sprites/ui/screens/events/HouseEvent/Trials/"+trialData._name+".png")
	id = _id

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			trial_chosen.emit(id)
