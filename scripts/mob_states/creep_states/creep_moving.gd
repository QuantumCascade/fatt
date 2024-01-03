class_name CreepMoving
extends CreepState


func enter() -> void:
	creep.play_anim("move")
	if creep.movement_target != Vector2.ZERO:
		creep.nav_agent.set_target_position(creep.movement_target)
	elif creep.visible_target:
		creep.nav_agent.set_target_position(creep.visible_target.global_position)


func exit():
	creep.stop_nav()
	creep.play_anim("idle")


func physics_process(delta: float):

	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
	
	if creep.movement_target == Vector2.ZERO:
		print("%s lost target" % creep)
		state_transition.emit(self, "Idle")
		return

	creep.check_attackable_targets()

	if creep.attack_target and creep.is_attackable(creep.attack_target):
		print("%s got to the target: %s" % [creep, creep.attack_target])
		state_transition.emit(self, "Attacking")
		return
	
	creep.check_visible_targets()
	
	if creep.visible_target:
		var dist_to_visible: float = creep.global_position.distance_squared_to(creep.visible_target.global_position)
		var dist_to_cur_mov_target: float = creep.global_position.distance_squared_to(creep.movement_target)
		if dist_to_visible < dist_to_cur_mov_target:
			# reroute
			creep.movement_target = creep.visible_target.global_position
			creep.nav_agent.set_target_position(creep.movement_target)
	elif creep.nav_agent.target_position != creep.movement_target:
		print("%s movement target changed to %s" % [creep, creep.movement_target])
		creep.nav_agent.set_target_position(creep.movement_target)
	
	creep.navigate(delta)
	
	if creep.velocity:
		creep.flip_to(creep.velocity)

