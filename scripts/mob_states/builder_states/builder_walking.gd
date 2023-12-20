class_name BuilderWalking
extends BuilderState


func enter() -> void:
	builder.anim_player.play("walk")
	if builder.movement_target != Vector2.ZERO:
		builder.nav_agent.set_target_position(builder.movement_target)


func exit():
	builder.stop_nav()
	builder.anim_player.play("idle")


func physics_process(delta: float):

	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return

	if builder.building_target && builder.movement_target == builder.building_target.global_position:
		if builder.in_building_area():
			builder.movement_target = Vector2.ZERO
			print("came to construction zone")
			state_transition.emit(self, "Building")
			return
		if builder.building_target.stats.building_time == 0:
			builder.building_target = null
			print("chaning plans - already somebody built that tower")
			builder.movement_target = Vector2.ZERO
			
	if builder.movement_target == Vector2.ZERO:
		print("changing plans - order cancelled")
		state_transition.emit(self, "Idle")
		return

	if builder.movement_target != builder.nav_agent.target_position:
		print("movement target changed to %s" % builder.movement_target)
		builder.nav_agent.target_position = builder.movement_target

	builder.navigate(delta)

	#if builder.velocity == Vector2.ZERO:
		#builder.movement_target = Vector2.ZERO
		#state_transition.emit(self, "Idle")
		#return
	
