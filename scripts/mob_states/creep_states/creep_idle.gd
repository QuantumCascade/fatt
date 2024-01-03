class_name CeepIdle
extends CreepState


func enter() -> void:
	creep.play_anim("idle")


func physics_process(_delta: float):
	
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
	
	if creep.movement_target != Vector2.ZERO:
		print("creep got new order - move to %s" % creep.movement_target)
		state_transition.emit(self, "Moving")
		return
	
	creep.check_attackable_targets()
	
	if creep.attack_target:
		print("creep see summoned close target - attacking: %s" % creep.attack_target)
		state_transition.emit(self, "Attacking")
		return
	
	creep.check_visible_targets()
	
	if creep.visible_target:
		print("%s spotted target - approaching: %s" % [creep, creep.visible_target])
		creep.movement_target = creep.visible_target.global_position
		state_transition.emit(self, "Moving")
		return

	var castle: Castle = get_tree().get_first_node_in_group("castle") as Castle
	if castle:
		creep.movement_target = castle.global_position
		print("%s moving to castle" % creep)
		state_transition.emit(self, "Moving")
		return

