extends Control
class_name Weather

@onready var weather : ColorRect = $Weather
@onready var sfx : AudioStreamPlayer = $Sfx

var presets : Dictionary = {
	"rain1" : {
		"size" : Vector2(0.005,0.2),
		"count" : 150,
		"slant" : -0.01,
		"speed" : 50,
		"blur" : 0.002
	},
	"rain2" : {
		"size" : Vector2(0.005,0.2),
		"count" : 250,
		"slant" : 0.079,
		"speed" : 50,
		"blur" : 0.002
	},
	"rain3" : {
		"size" : Vector2(0.007,0.2),
		"count" : 300,
		"slant" : 0.1,
		"speed" : 50,
		"blur" : 0.002
	},
	"snow1" :  {
		"size" : Vector2(0.02,0.02),
		"count" : 100,
		"slant" : -0.01,
		"speed" : 12.81,
		"blur" : 0.002
	},
	"snow2" :  {
		"size" : Vector2(0.02,0.02),
		"count" : 200,
		"slant" : -0.01,
		"speed" : 14.81,
		"blur" : 0.002
	},
	"snow3" :  {
		"size" : Vector2(0.02,0.02),
		"count" : 500,
		"slant" : -0.01,
		"speed" : 16.81,
		"blur" : 0.002
	}
}

func stop() -> void:
	weather.visible = false
	sfx.stop()

func start(preset : String) -> void:
	weather.visible = true
	for parameter : String in presets[preset].keys():
		weather.material.set_shader_parameter(parameter,presets[preset][parameter])
	sfx.play()
