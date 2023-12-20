class_name Steering
extends Node2D


const major_context_collision_points: float = 1.0
const minor_context_collision_points: float = 0.65


@export var steering_amplifier = 15

@export var radius: float = 25
	#set(new_radius):
		#radius = new_radius
		#setup_directions()


var directions: Array[RayCast2D] = []


func _ready():
	for dir in Vectors.directions:
		var ray: RayCast2D = RayCast2D.new()
		ray.target_position = dir
		ray.collide_with_areas = true
		#ray.visible = true
		add_child(ray)
		directions.append(ray)
	setup_directions()


func setup_directions():
	for direction in directions:
		direction.target_position = direction.target_position.normalized() * radius


func process(current_velocity: Vector2, desired_velocity: Vector2, delta: float) -> Vector2:
	var adjusted_direction = get_adjusted_direction(desired_velocity)
	var current_direction = current_velocity.normalized()
	var steering_force: Vector2 = (adjusted_direction - current_direction) * steering_amplifier * delta
	return (current_direction + steering_force).normalized()


func get_adjusted_direction(desired_velocity: Vector2) -> Vector2:
	var interest: Array[float] = calc_interest(desired_velocity.normalized())
	var danger: Array[float] = get_collision_points()
	for i in range(8):
		interest[i] -= danger[i]
	var output_direction: Vector2 = Vector2()
	for i in range(8):
		output_direction += Vectors.directions[i] * interest[i]
	return output_direction.normalized()


func calc_interest(desired_vector: Vector2) -> Array[float]:
	return [
		Vectors.up.dot(desired_vector),
		Vectors.up_right.dot(desired_vector),
		Vectors.right.dot(desired_vector),
		Vectors.down_right.dot(desired_vector),
		Vectors.down.dot(desired_vector),
		Vectors.down_left.dot(desired_vector),
		Vectors.left.dot(desired_vector),
		Vectors.up_left.dot(desired_vector),
	]


func get_collision_points() -> Array[float]:
	var colliders: Array[bool] = [false, false, false, false, false, false, false, false]
	for i in range(8):
		colliders[i] = directions[i].is_colliding()
	var points: Array[float] = [0, 0, 0, 0, 0, 0, 0, 0]
	for i in range(8):
		var left = 7 if i-1 < 0 else i-1
		var right = 0 if i+1 > 7 else i+1
		points[i] = calc_collision_points(colliders[i], colliders[left], colliders[right])
	return points


func calc_collision_points(major_collision: bool, \
		minor_collision_left: bool, minor_collision_right: bool) -> float:
	var points = major_context_collision_points if major_collision else 0.0
	if minor_collision_left:
		points += minor_context_collision_points
	if minor_collision_right:
		points += minor_context_collision_points
	return points
