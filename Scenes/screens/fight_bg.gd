extends Node2D
class_name FightBg

var current_stage : String = "forest"

func set_bg(stage : String) -> void:
	current_stage = stage
	match stage:
		"forest":
			$Forest.visible = true
			$Snow.visible = false
		"snow":
			$Forest.visible = false
			$Snow.visible = true

func set_dazed_color() -> void:
	if current_stage == "forest":
		$Forest/CanvasModulate.color = "7a7d82"
	else:
		$Snow/CanvasModulate.color = "7a7d82"

func restore_dazed_color() -> void:
	if current_stage == "forest":
		$Forest/CanvasModulate.color = "a1b0c5"
	else:
		$Snow/CanvasModulate.color = "ffffff"
		
