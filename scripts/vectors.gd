extends Node
class_name Vectors

const up = Vector2(0, -1)
const up_right = Vector2(1, -1)
const right = Vector2(1, 0)
const down_right = Vector2(1, 1)
const down = Vector2(0, 1)
const down_left = Vector2(-1, 1)
const left = Vector2(-1, 0)
const up_left = Vector2(-1, -1)

const directions: Array[Vector2] = [
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
