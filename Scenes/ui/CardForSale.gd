extends Control
class_name CardForSaleScene
signal card_chosen(id)

@onready var rewardCard = $RewardCard
@onready var costLabel = $RewardCard/CostLabel
var hit_material = preload("res://Shaders/hit_shader.tres").duplicate(true)
var price : int
var id : int
var animating = false
var card_data
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_data(card_data : CardData, price : int,id:int):
	self.price = price
	self.id = id
	self.card_data = card_data
	rewardCard.set_data(card_data,id,true)
	rewardCard.card_chosen.connect(card_clicked)
	costLabel.text = "[center]"+str(price)+"[img=64]res://Sprites/ui/rewardIcons/gold.png[/img]"


func card_clicked(id:int):
	db.clickPlayer.play()
	if db.player.gold >= price:
		card_chosen.emit(id)
	elif !animating:
		rewardCard.sprite.material = hit_material
		animating = true
		var tween = create_tween()
		rewardCard.sprite.material.set_shader_parameter("hit_color",Color("a94949"))
		tween.tween_method(func(value): rewardCard.sprite.material.set_shader_parameter("time", value),0.0,1.0,0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(func(): animating = false)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
