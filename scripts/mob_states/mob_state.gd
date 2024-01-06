class_name MobState
extends State

var mob: Mob

func setup(an_actor: Node):
	super.setup(an_actor)
	assert(an_actor is Mob)
	mob = an_actor as Mob


func _castle() -> Castle:
	return get_tree().get_first_node_in_group("castle") as Castle


func disposable_timer(callback: Callable, wait_time: float) -> Timer:
	var timer: Timer = Timer.new()
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = wait_time
	timer.timeout.connect(callback)
	return timer
