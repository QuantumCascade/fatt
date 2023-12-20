extends Camera2D
class_name Cam

var zoom_target: Vector2 = Vector2.ONE
var zoom_speed: Vector2 = Vector2(2, 2)
var zoom_epsilon: float = .01

func _process(delta):
	if zoom == zoom_target:
		return
	if zoom.distance_squared_to(zoom_target) < zoom_epsilon:
		zoom = zoom_target
		return
	if zoom.x < zoom_target.x:
		zoom += zoom_speed * delta
	else:
		zoom = zoom_target
		
