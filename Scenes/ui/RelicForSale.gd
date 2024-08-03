extends Control

class_name RelicForSaleScene

signal relic_chosen(id)
@onready var sprite = $Sprite
@onready var costLabel = $Sprite/CostLabel
@onready var tooltip : TooltipNode = $Tooltip
var outline_material = preload("res://Shaders/outline.tres")
var hit_material = preload("res://Shaders/hit_shader.tres").duplicate(true)
var relic_data : RelicData
var id

var animating = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_data(data: RelicData,relic_id:int):
	relic_data = data
	id = relic_id
	tooltip.set_data(relic_data.description)
	sprite.texture = load("res://Sprites/ui/relics/"+relic_data._name+".png")
	costLabel.text = "[center]"+str(relic_data.cost)+"[img=16]res://Sprites/ui/rewardIcons/gold.png[/img]"

func _on_mouse_entered():
	if !animating:
		sprite.material = outline_material
		tooltip.visible = true


func _on_mouse_exited():
	if !animating:
		sprite.material = null
		tooltip.visible = false


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			if db.player.gold >= relic_data.cost:
				relic_chosen.emit(id)
			elif !animating:
				sprite.material = hit_material
				tooltip.visible = false
				animating = true
				var tween = create_tween()
				sprite.material.set_shader_parameter("hit_color",Color("a94949"))
				tween.tween_method(func(value): sprite.material.set_shader_parameter("time", value),0.0,1.0,0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
				tween.tween_callback(func(): animating = false)
