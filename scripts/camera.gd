extends Camera2D
class_name Cam

var zoom_orig: Vector2
var zoom_target: Vector2
var zoom_speed: Vector2 = Vector2(2, 2)
var zoom_epsilon: float = .01

var dragging: bool = false


@onready var viewport_size: Vector2i = get_viewport().size / 2

func _ready():
	zoom_target = self.zoom
	zoom_orig = self.zoom

func is_dragging() -> bool:
	return dragging

func smoothly_zoom(new_zoom: Vector2):
	zoom_orig = self.zoom
	zoom_target = new_zoom

func unzoom():
	zoom_target = zoom_orig

func _process(delta: float):
	process_zoom(delta)


func process_zoom(delta: float):
	if zoom == zoom_target:
		return
	if zoom.distance_squared_to(zoom_target) < zoom_epsilon:
		zoom = zoom_target
		return
	if zoom.x < zoom_target.x:
		zoom += zoom_speed * delta
	else:
		zoom -= zoom_speed * delta


func _unhandled_input(event: InputEvent):
	if not event is InputEventMouseMotion:
		return
	var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
	if not mouse_motion.button_mask == MOUSE_BUTTON_MASK_LEFT:
		if dragging:
			dragging = false
			print("dragging off")
		return
	if mouse_motion.relative:
		dragging = true
		position -= mouse_motion.relative / zoom
		return
