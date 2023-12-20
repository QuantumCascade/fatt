class_name Mob
extends CharacterBody2D

var stats: MobStats = MobStats.new()
var movement_target: Vector2 = Vector2()


func get_nav_agent() -> NavAgent:
	return null
	
func get_steering() -> Steering:
	return null


func init_from_stats(mob_stats: MobStats):
	stats = mob_stats.clone()
	if get_nav_agent():
		get_nav_agent().max_speed = stats.movement_speed


func take_dmg(dmg: float):
	stats.hp = max(stats.hp - dmg, 0)


func navigate(delta: float):
	if get_nav_agent().is_navigation_finished():
		stop_nav()
		return
	var next_path_position: Vector2 = get_nav_agent().get_next_path_position()
	var navigation_vector: Vector2 = next_path_position - global_position
	var steering_vector: Vector2 = get_steering().process(velocity, navigation_vector, delta).normalized()
	var desired_velocity = steering_vector * stats.movement_speed
	if get_nav_agent().avoidance_enabled:
		get_nav_agent().velocity = desired_velocity
	else:
		velocity = desired_velocity
		move_and_slide()
	


func _on_nav_agent_velocity_computed(safe_velocity: Vector2):
	if get_nav_agent().is_navigation_finished() || movement_target == Vector2.ZERO:
		velocity = Vector2()
		return
	if get_nav_agent().avoidance_enabled:
		velocity = safe_velocity
		move_and_slide()


func stop_nav():
	print("stop_nav")
	movement_target = Vector2()
	get_nav_agent().target_position = Vector2()
	velocity = Vector2()
