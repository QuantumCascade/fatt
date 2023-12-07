class_name Projectile extends CharacterBody2D

const GRAVITY = 10

var accel: float = 250.0

var attacker: Node2D
var target: Unit

var from: Vector2
var vertex: Vector2
var dir
var p

func launch(subj: Node2D):
	self.attacker = subj
	from = global_position
	from.y = from.y 
	var predicted_target_pos = target.get_pos_after(accel / 1000)
	var tx = predicted_target_pos.x
	var ty = predicted_target_pos.y
	var x = from.x
	var y = from.y
	dir = from.direction_to(Vector2(tx, ty))
	var vx = x + (tx - x) / 2
	var vy = min(from.y, ty) - 100
	vertex = Vector2(vx, vy)
	p = pow(x - vx, 2) / (4 * (y - vy))
	print("launch from " + str(from) + " to " + str(target.global_position) + " with predicted at " + str(predicted_target_pos))
	print("Vertex at: " + str(vertex) + " | p=" + str(p))


func calc_motion(at_x: float) -> Vector2:
	var at_y = pow(at_x - vertex.x, 2) / (4 * p) + vertex.y
	#print("Shifting on x from: " + str(global_position.x) + " to " + str(at_x))
	return Vector2(at_x, at_y)


func _physics_process(delta):
	var motion: Vector2 = calc_motion(global_position.x + dir.x * delta * accel)
	#if randf() < (1./30.):
		#print("Flying from " + str(global_position) + " to " + str(motion))
	velocity = global_position.direction_to(motion) * accel
	if global_position.y > target.global_position.y && velocity.y > 0:
		velocity = Vector2.ZERO
		return
	rotation = velocity.angle()
	move_and_slide()


func _on_timer_timeout():
	queue_free()


func _on_area_2d_body_entered(body):
	if Util.is_attackable_enemy(attacker, body):
		print("projectile hit >> " + str(body))
		body.receive_dmg(50, attacker)
		queue_free()
