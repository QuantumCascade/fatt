class_name BuilderIdle
extends BuilderState


var resting_time_on_idle: float = 0.75
# if resting then wait for a while before looking for new opportunities
var resting_time: float

func enter() -> void:
	resting_time = resting_time_on_idle
	builder.play_anim("idle_2")
	setup_anim_timer()


func setup_anim_timer():
	add_child(disposable_timer(play_idle_anim, randf_range(5, 20)))


func play_idle_anim():
	if not is_inside_tree():
		return # if detached from state machine then ignore timer signal
	builder.play_anim("idle")
	setup_anim_timer()


func exit():
	pass


func physics_process(delta: float):
	
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
	
	resting_time = max(resting_time - delta, 0)
	
	if resting_time > 0:
		return

	if builder.movement_target != Vector2.ZERO:
		print("%s got new order - move to %s" % [builder, builder.movement_target])
		state_transition.emit(self, "Walking")
		return
	
	builder.check_pending_towers()
	
	if builder.building_target:
			if builder.building_target.stats.building_time > 0:
				if builder.in_building_area():
					state_transition.emit(self, "Building")
				else:
					builder.movement_target = builder.building_target.global_position
					print("found new construction zone - going there %s" % builder.movement_target)
					state_transition.emit(self, "Walking")
				return
			else:
				builder.building_target = null

	var spawn_area: PlayerSpawnArea = _spawn_area()
	if spawn_area && !spawn_area.get_overlapping_bodies().has(builder):
		builder.movement_target = spawn_area.global_position
		print("going home")
		state_transition.emit(self, "Walking")
		return
	
