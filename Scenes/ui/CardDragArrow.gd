extends Control

@onready var arrowhead = $Sprite2D
@onready var arrowbody = $Sprite2D/ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_data(from : Vector2, to: Vector2,animate: bool = false):
	var new_from = from - Vector2(0,300)
	var new_to = to 
	var direction = new_to - new_from
	var distance = direction.length()
	var angle = direction.angle()
	
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN)
	var t = 0 if !animate else 0.1
	tween.tween_property(arrowhead,"global_position",new_to,t)
	tween.tween_property(arrowhead,"rotation",PI/2 + angle,t)
	tween.tween_property(arrowbody,"global_position",new_from,t)
	tween.tween_property(arrowbody,"size:y",distance / 2,t)
	tween.tween_property(arrowbody,"position:x",-arrowbody.size.x / 2 ,t)
	
func _process(delta):
	pass
