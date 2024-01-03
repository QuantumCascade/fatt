class_name ArcherMoving
extends ArcherState


var moving_intention_time_on_start: float = 1.0
var moving_intention_time_on_refresh: float = 0.5
# if intention is strong then do not change plans on its own immediately
var moving_intention_time: float 


func enter() -> void:
	mob.play_anim("move")
	if mob.movement_target != Vector2.ZERO:
		mob.nav_agent.set_target_position(mob.movement_target)
	moving_intention_time = moving_intention_time_on_start
	#archer.nav_agent.target_desired_distance = 1 # wtf


func exit():
	mob.stop_nav()
	mob.play_anim("idle")


func physics_process(delta: float):

	if not mob:
		return
	
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
	
	moving_intention_time = max(moving_intention_time - delta, 0)
	
	#if archer.assigned_tower && archer.assigned_tower.is_in_loading_zone(archer.movement_target):
	if archer.assigned_tower and archer.is_in_assigned_tower_area():
		archer.assigned_tower.load_minion(archer)
		state_transition.emit(self, "Idle")
		return

	if archer.check_enemies_in_attack_area():
		print("%s enemy in attack range: %s" % [archer, archer.enemy_to_attack])
		state_transition.emit(self, "Attacking")
		return


	if mob.nav_agent.is_navigation_finished():
		print("%s got to the nav position %s ~ %s" % [mob, mob.movement_target, mob.global_position.distance_to(mob.movement_target)])
		state_transition.emit(self, "Idle")
		return
	
	if mob.movement_target == Vector2.ZERO:
		print("%s changing plans - order cancelled" % mob)
		state_transition.emit(self, "Idle")
		return

	if mob.movement_target != mob.nav_agent.target_position:
		print("%s movement target changed to %s" % [mob, mob.movement_target])
		mob.nav_agent.target_position = mob.movement_target
	
	mob.navigate(delta)
	
	if mob.velocity:
		mob.flip_to(mob.velocity)
	
