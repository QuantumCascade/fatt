extends Node2D



func _ready():
	$Unit.movement_speed = 20

func _on_timer_timeout():
	var rnd = randf()
	print("rnd %s" % rnd)
	if randf() < .3:
		$Unit.set_movement_target($Tower3)
	elif randf() < .6:
		$Unit.set_movement_target($Tower4)
	else:
		$Unit.set_movement_target($Tower5)
