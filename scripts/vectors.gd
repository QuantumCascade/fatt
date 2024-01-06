extends Node
class_name Vectors

const up = Vector2(0, -1)
static var up_right = Vector2(1, -1).normalized()
const right = Vector2(1, 0)
static var down_right = Vector2(1, 1).normalized()
const down = Vector2(0, 1)
static var down_left = Vector2(-1, 1).normalized()
const left = Vector2(-1, 0)
static var up_left = Vector2(-1, -1).normalized()

static var directions: Array[Vector2] = [
	up,
	up_right,
	right,
	down_right,
	down,
	down_left,
	left,
	up_left
]

func get_interest_vector(desired_vector: Vector2) -> Array[float]:
	return [
		up.dot(desired_vector),
		up_right.dot(desired_vector),
		right.dot(desired_vector),
		down_right.dot(desired_vector),
		down.dot(desired_vector),
		down_left.dot(desired_vector),
		left.dot(desired_vector),
		up_left.dot(desired_vector),
	]
