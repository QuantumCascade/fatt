class_name ArcherIdle
extends ArcherState


var resting_time_on_idle: float = 0.5
# if resting then wait for a while before looking for new opportunities
var resting_time: float


func enter() -> void:
	archer.play_anim("idle")
	resting_time = resting_time_on_idle


func exit():
	pass


func physics_process(delta: float):
	
	if not mob:
		return
	
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
	
	resting_time = max(resting_time - delta, 0)
	
	if resting_time > 0:
		return

	if archer.check_enemies_in_attack_area():
		print("%s sudden enemy in attack area: %s" % [archer, archer.enemy_to_attack])
		state_transition.emit(self, "Attacking")
	
	if archer.check_visible_enemies():
		print("%s spotted enemy - approaching %s" % [archer, archer.enemy_to_attack])
		archer.movement_target = archer.enemy_to_attack.global_position
		state_transition.emit(self, "Moving")
		return

	if archer.movement_target != Vector2.ZERO:
		print("%s got new order - move to %s" % [archer, archer.movement_target])
		state_transition.emit(self, "Moving")
		return

	if archer.check_assigned_tower():
		archer.movement_target = archer.assigned_tower.global_position
		#archer.movement_target = archer.assigned_tower.get_nearest_loading_point(archer.global_position)
		print("%s going to %s" % [archer, archer.assigned_tower])
		state_transition.emit(self, "Moving")
		return

	var spawn_area: PlayerSpawnArea = _spawn_area()
	if spawn_area && !spawn_area.get_overlapping_bodies().has(archer):
		archer.movement_target = spawn_area.global_position
		print("%s going home" % archer)
		state_transition.emit(self, "Walking")
		return

