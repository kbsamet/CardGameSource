extends Control
class_name CardForSaleScene
signal card_chosen(id : int)

@onready var rewardCard : RewardCardScene= $RewardCard
@onready var costLabel : RichTextLabel  = $RewardCard/CostLabel
var hit_material : ShaderMaterial = preload("res://Shaders/hit_shader.tres").duplicate(true)
var price : int
var id : int
var animating : bool = false
var card_data : CardData
# Called when the node enters the scene tree for the first time.
func _ready()-> void:
	pass # Replace with function body.

func set_data(card_data : CardData, price : int,id:int)-> void:
	self.price = price
	self.id = id
	self.card_data = card_data
	rewardCard.set_data(card_data,id,true)
	rewardCard.card_chosen.connect(card_clicked)
	costLabel.text = "[center]"+str(price)+"[img=64]res://Sprites/ui/rewardIcons/gold.png[/img]"


func card_clicked(id:int)-> void:
	db.clickPlayer.play()
	if db.player.gold >= price:
		card_chosen.emit(id)
	elif !animating:
		rewardCard.sprite.material = hit_material
		animating = true
		var tween : Tween = create_tween()
		rewardCard.sprite.material.set_shader_parameter("hit_color",Color("a94949"))
		tween.tween_method(func(value: float) -> void: rewardCard.sprite.material.set_shader_parameter("time", value),0.0,1.0,0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(func() -> void: animating = false)
	
