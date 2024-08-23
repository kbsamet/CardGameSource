extends Node2D
class_name CardDragArrow
@onready var arrowhead : Sprite2D = $Sprite2D
@onready var arrowbody : Panel = $Sprite2D/ColorRect
var points : PackedVector2Array

func set_data(from : Vector2, to: Vector2,animate: bool = false) -> void:
	if to.y + 200 > from.y:
		points = []
		visible = false
		return
	visible = true
	var new_from : Vector2= from - Vector2(0,200)
	var new_to: Vector2 = to 
	var direction: Vector2 = new_to - new_from
	var distance: float = direction.length()
	var angle: float = direction.angle()
	
	var tween : Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN)
	var t: float = 0.0 if !animate else 0.1
	tween.tween_property(arrowbody,"global_position",new_from,t)
	tween.tween_property(arrowbody,"size:y",distance / 2,t)
	tween.tween_property(arrowbody,"position:x",-arrowbody.size.x / 2 ,t)
	
	points = []
	var steepness: float = 2/abs(PI/2- angle) 
	var mid_point : Vector2 = new_from.lerp(new_to,0.5) +(Vector2(-(distance/2)*steepness,0) if new_from.x < get_viewport_rect().size.x /2 else Vector2(distance*steepness/2,0))
	#points.push_back(new_from)
	#points.push_back(mid_point)
	#points.push_back(new_to)
	for time in range(0,1000,1):
		points.push_back(_quadratic_bezier(new_from - global_position, mid_point - global_position, new_to - global_position,time/1000.0))
	var new_angle: float = PI/2 + (points[points.size()-1] - points[points.size()-100]).angle()
	tween.tween_property(arrowhead,"rotation",new_angle,t)
	tween.tween_property(arrowhead,"global_position",new_to,t)
	queue_redraw()

func _draw() -> void:
	if points:
		draw_polyline(points,Color.WHITE,32)
		draw_polyline(points,Color("a94949"),26)

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 : Vector2 = p0.lerp(p1, t)
	var q1: Vector2 = p1.lerp(p2, t)
	var r: Vector2 = q0.lerp(q1, t)
	return r 
