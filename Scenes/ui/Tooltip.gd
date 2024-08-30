extends Control
class_name TooltipNode
@onready var InfoBox : Panel = $InfoBox
@onready var descriptionLabel : RichTextLabel = $InfoBox/InfoLabel
var text : String = ""

func set_data(tooltip: String,_scale :Vector2 = Vector2(1,1)) -> void:
	text = tooltip
	descriptionLabel.text = add_colors_to_text(text)
	scale = _scale
	#var scale_factor = _scale / get_global_transform().get_scale()
	#var newSize = Vector2(InfoBox.size.x * scale_factor.x, InfoBox.size.y * scale_factor.y)
	#InfoBox.size = newSize
	#descriptionLabel.scale = scale_factor
	InfoBox.size.y = descriptionLabel.get_minimum_size().y + 30 #+ (40 if get_global_transform().get_scale() == _scale else 0)
	#if _scale != Vector2(1,1):
		#InfoBox.size.y = descriptionLabel.get_minimum_size().y + 45 * _scale.y
	InfoBox.custom_minimum_size = InfoBox.size

func add_colors_to_text(s : String) -> String:
	var strs : PackedStringArray = s.split(":")
	strs[0] = "[color=e8c65b]"+ strs[0] + "[/color]"
	return strs[0] + ":\n" + strs[1]
