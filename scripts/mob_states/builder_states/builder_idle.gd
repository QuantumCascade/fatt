class_name BuilderIdle
extends BuilderState

var building_area_dist: float = 50

func enter() -> void:
	builder.anim_player.play("idle")


func exit():
	pass


func physics_process(_delta: float):
	
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
	
	if builder.movement_target != Vector2.ZERO:
		print("got new order - move to %s" % builder.movement_target)
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

	var spawn_area: SpawnArea = get_tree().get_first_node_in_group("player_spawn_area") as SpawnArea
	if spawn_area && !spawn_area.get_overlapping_bodies().has(builder):
		builder.movement_target = spawn_area.global_position
		print("going home")
		state_transition.emit(self, "Walking")
		return
	
