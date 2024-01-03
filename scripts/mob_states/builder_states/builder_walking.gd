class_name BuilderWalking
extends BuilderState


var moving_intention_time_on_start: float = 1.0
var moving_intention_time_on_refresh: float = 0.5
# if intention is strong then do not change plans on its own immediately
var moving_intention_time: float 


func enter() -> void:
	builder.play_anim("move")
	if builder.movement_target != Vector2.ZERO:
		builder.nav_agent.set_target_position(builder.movement_target)
	moving_intention_time = moving_intention_time_on_start


func exit():
	builder.stop_nav()
	builder.play_anim("idle")


func physics_process(delta: float):

	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
	
	moving_intention_time = max(moving_intention_time - delta, 0)

	if builder.building_target && builder.movement_target == builder.building_target.global_position:
		if builder.in_building_area():
			builder.movement_target = Vector2.ZERO
			print("builder came to construction zone")
			state_transition.emit(self, "Building")
			return
		if builder.building_target.stats.building_time == 0 and moving_intention_time == 0:
			builder.building_target = null
			print("builder chaning plans - already somebody built that tower")
			builder.movement_target = Vector2.ZERO
			return
	
	if builder.nav_agent.is_navigation_finished():
		print("builder got to the position")
		state_transition.emit(self, "Idle")
		return
	
	if builder.movement_target == Vector2.ZERO:
		print("builder changing plans - order cancelled")
		state_transition.emit(self, "Idle")
		return

	if builder.movement_target != builder.nav_agent.target_position:
		print("%s movement target changed to %s" % [builder, builder.movement_target])
		builder.nav_agent.target_position = builder.movement_target
	
	# if going to spawn then check if there are pending towers appeared from time to time
	var spawn_area: PlayerSpawnArea = _spawn_area()
	if spawn_area and builder.movement_target == spawn_area.global_position \
			and moving_intention_time == 0:
		if not builder.building_target:
			builder.check_pending_towers()
		if not builder.building_target:
			moving_intention_time = moving_intention_time_on_refresh
		else:
			print("%s found a new tower to build %s" % [builder, builder.building_target])
			builder.movement_target = builder.building_target.global_position
		

	builder.navigate(delta)
	
	if builder.velocity:
		builder.flip_to(builder.velocity)
	
