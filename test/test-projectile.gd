extends Node2D


var markers = []
@onready var u: Unit = $Unit

func _ready():
	markers.append($Marker1)
	markers.append($Marker2)
	markers.append($Marker3)
	markers.append($Marker4)
	#u.movement_speed = 100
	#u.set_movement_target(markers[0])
	
func _input(event):
	if event.is_action_pressed("click"):
		$Marker1.position = get_global_mouse_position()
		u.set_movement_target($Marker1)

#func _physics_process(delta):
	#var dist = u.position.distance_to(u.current_target.position)
	#if dist <= 50:
		#markers.append(markers.pop_front())
		#u.set_movement_target(markers[0])


#func _on_timer_timeout():
	#var rnd = randf()
	#print("rnd %s" % rnd)
	#if randf() < .3:
		#$Unit.set_movement_target($Tower3)
	#elif randf() < .6:
		#$Unit.set_movement_target($Tower4)
	#else:
		#$Unit.set_movement_target($Tower5)
