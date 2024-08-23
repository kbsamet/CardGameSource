extends Control

class_name RelicForSaleScene

signal relic_chosen(id:int)
@onready var sprite : Sprite2D = $Sprite
@onready var costLabel : RichTextLabel = $CostLabel
@onready var tooltip : TooltipNode = $Tooltip
var outline_material : ShaderMaterial = preload("res://Shaders/outline.tres")
var hit_material : ShaderMaterial = preload("res://Shaders/hit_shader.tres").duplicate(true)
var relic_data : RelicData
var id : int

var animating : bool = false
func set_data(data: RelicData,relic_id:int) -> void:
	relic_data = data
	id = relic_id
	tooltip.set_data(relic_data.description)
	sprite.texture = load("res://Sprites/ui/relics/"+relic_data._name+".png")
	costLabel.text = "[center]"+str(relic_data.cost)+"[img=16]res://Sprites/ui/rewardIcons/gold.png[/img]"
	if sprite.texture.get_width() == 64:
		sprite.scale /= 2
func _on_mouse_entered() -> void:
	if !animating:
		sprite.material = outline_material
		tooltip.visible = true


func _on_mouse_exited() -> void:
	if !animating:
		sprite.material = null
		tooltip.visible = false


func _on_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			db.clickPlayer.play()
			if db.player.gold >= relic_data.cost:
				relic_chosen.emit(id)
			elif !animating:
				sprite.material = hit_material
				tooltip.visible = false
				animating = true
				var tween : Tween = create_tween()
				sprite.material.set_shader_parameter("hit_color",Color("a94949"))
				tween.tween_method(func(value : float) -> void: sprite.material.set_shader_parameter("time", value),0.0,1.0,0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
				tween.tween_callback(func() -> void: animating = false)
