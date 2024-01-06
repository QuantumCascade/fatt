class_name Mob
extends CharacterBody2D

## Abstract class for any game object able to navigate itself without player control

# Each ancestor should set this components during setup/init 
var state_machine: StateMachine
var steering: Steering
var nav_agent: NavAgent
var audible: AudioStreamPlayer2D

var stats: MobStats = MobStats.new()
var movement_target: Vector2 = Vector2()

var mass: float = 1.0
var pushed_force: Vector2= Vector2.ZERO


# Emits self
signal death_animation_performed


func setup(new_stats: MobStats):
	stats = new_stats.clone()
	nav_agent.max_speed = stats.movement_speed
	nav_agent.velocity_computed.connect(_on_nav_agent_velocity_computed)


func play_audio(_sound: String):
	pass

func play_anim(_anim_name: String):
	pass

func flip_to(_dir: Vector2):
	pass


func finally_decayed():
	print("release decayed body: %s" % self)
	queue_free()


func take_dmg(dmg: float):
	var prev_hp: float = stats.hp
	stats.hp = max(stats.hp - dmg, 0)
	print("%s: took dmg=%s | hp: %s -> %s" % [self, dmg, prev_hp, stats.hp])
	play_audio("hit_hurt")


func take_push(force: Vector2):
	pushed_force += force / mass


func _physics_process(delta: float):
	if pushed_force != Vector2.ZERO:
		var desired_velocity = merge_pushed_force(Vector2.ZERO, delta)
		move_and_slide_with_velocity(desired_velocity, delta)
		velocity = Vector2.ZERO


func navigate(delta: float):
	if not nav_agent:
		print("%s failed to nav without agent")
		return
	if nav_agent.is_navigation_finished():
		print("%s nav complete" % self)
		stop_nav()
		return
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var navigation_vector: Vector2 = next_path_position - global_position
	if navigation_vector.length() < steering.radius:
		velocity = navigation_vector.normalized() * stats.movement_speed
		move_and_slide_with_velocity(velocity, delta)
		return
	var steering_vector: Vector2 = steering.process(velocity, navigation_vector, delta).normalized()
	var desired_velocity = steering_vector * stats.movement_speed
	if nav_agent.avoidance_enabled:
		nav_agent.velocity = desired_velocity
	else:
		move_and_slide_with_velocity(desired_velocity, delta)


func move_and_slide_with_velocity(desired_velocity: Vector2, _delta: float):
	velocity = desired_velocity
	move_and_slide()
	if velocity != Vector2.ZERO:
		var collision:  KinematicCollision2D = get_last_slide_collision()
		if collision and collision.get_collider() is Mob:
			var other: Mob = collision.get_collider() as Mob
			if other.pushed_force == Vector2.ZERO:
				var disposition: Vector2 = (other.global_position - global_position).normalized()
				if disposition.dot(desired_velocity.normalized()) > 0.5:
					var push_dir: Vector2 = desired_velocity.reflect(disposition).normalized()
					other.take_push(mass * push_dir * 50)
			if is_friend(other):
				other.friendly_asked_to_move()


func friendly_asked_to_move():
	pass


func is_friend(other: Mob) -> bool:
	return is_in_group("player_minions") and other.is_in_group("player_minions") \
		or is_in_group("enemy_mobs") and other.is_in_group("enemy_mobs")


func merge_pushed_force(vec: Vector2, delta: float) -> Vector2:
	if pushed_force == Vector2.ZERO:
		return vec
	if pushed_force.length_squared() < 1:
		pushed_force = Vector2.ZERO
		return vec
	var pushed: Vector2 = delta * pushed_force
	pushed_force -= pushed
	return vec + pushed


func _on_nav_agent_velocity_computed(safe_velocity: Vector2):
	if nav_agent.is_navigation_finished() || movement_target == Vector2.ZERO:
		velocity = Vector2()
		return
	if nav_agent.avoidance_enabled:
		velocity = safe_velocity
		move_and_slide()


func stop_nav():
	movement_target = Vector2()
	nav_agent.target_position = Vector2()
	velocity = Vector2()


func get_pos_after(delta: float) -> Vector2:
	return global_position + velocity * delta


func choose_closest(n1: Node2D, n2: Node2D) -> bool:
	var d1: float = global_position.distance_squared_to(n1.global_position)
	var d2: float = global_position.distance_squared_to(n2.global_position)
	if d1 < d2:
		return true
	return false


func _to_string():
	return "mob at %s" % global_position
