extends Control
class_name TooltipNode
@onready var InfoBox = $InfoBox
@onready var descriptionLabel = $InfoBox/InfoLabel
var text = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_data(tooltip: String):
	text = tooltip
	descriptionLabel.text = text
	var scale_factor = Vector2(1,1) / get_global_transform().get_scale()
	var newSize = Vector2(InfoBox.size.x * scale_factor.x, InfoBox.size.y * scale_factor.y)
	InfoBox.size = newSize
	descriptionLabel.scale = scale_factor
	InfoBox.size.y = descriptionLabel.get_minimum_size().y + (40 if get_global_transform().get_scale() == Vector2(1,1) else 0)
	InfoBox.custom_minimum_size = InfoBox.size
