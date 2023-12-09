class_name Projectile extends CharacterBody2D

const kind: String = "Projectile"

var attack_strength: float = 50.0
var accel: float = 250.0

var attacker: Node2D # object launched this projectile
var target: Unit # intended target

var from: Vector2 # global coordinates
var to: Vector2 # global coordinates
var vertex: Vector2 # parabolic vertex
var dir: Vector2 # original direction - normalized vector
var parabolic: Parabolic # parabolic coefficients
var arc_height = 100.0 # parabolic vertex height
var wasted: bool = false
var is_stuck: bool = false

var wasted_alpha_delta: float = 10

func launch(subj: Node2D, to_target: Vector2):
	attacker = subj
	from = self.global_position
	to = to_target
	dir = from.direction_to(to)
	var vx = from.x + (to.x - from.x) / 2 # vertex X in the midpint
	var vy = min(from.y, to.y) - arc_height # vertex Y with the given arc height
	vertex = Vector2(vx, vy) # parabolic vertex
	parabolic = Parabolic.calculate([from, to, vertex])
	print("Launch from %s to %s with vertex %s and coefficient %s" % [from, to, vertex, parabolic])
	#mark_at(vertex, Color.BLUE)
	#mark_at(to, Color.RED)


# calculate next coordinates
func calc_motion(x: float) -> Vector2:
	if wasted || is_stuck:
		return Vector2.ZERO
	var y = parabolic.calc_y(x)
	if y == NAN:
		print_debug("lost")
		queue_free()
	return Vector2(x, y)

func _physics_process(delta: float):
	if wasted:
		decay_wasted(delta)
		return
	if is_stuck:
		return
	#var aim: Vector2 = global_position.direction_to(to)
	var next_pos: Vector2 = calc_motion(global_position.x + dir.x * delta * accel)
	velocity = global_position.direction_to(next_pos) * accel
	if global_position.y > to.y && velocity.y > 0:
		print("wasted " + str(self))
		velocity = Vector2.ZERO
		wasted = true
		$CollisionShape2D.disabled = true
		$Area2D.monitoring = false
		return
	rotation = velocity.angle()
	global_position = next_pos
	#move_and_slide()

# cleanup
func _on_timer_timeout():
	queue_free()


func _on_area_2d_body_entered(body):
	if wasted || is_stuck:
		return
	if Util.is_attackable_enemy(attacker, body):
		print("projectile hit >> " + str(body))
		var dmg = Util.calc_dmg(self, body)
		body.receive_dmg(dmg, attacker)
		# this should be cool - stuck into the enemy body ^_^
		print("%s stuck in %s" % [self, body])
		is_stuck = true
		call_deferred("attach_to_body", body)
		
		
func attach_to_body(body):
	reparent(body)
	$Area2D.monitoring = false
	$CollisionShape2D.disabled = true

func decay_wasted(delta: float):
	var color: Color = $Sprite2D.modulate
	if color.a <= 0:
		print("wipe projectile finally %s" % str(global_position))
		queue_free()
		return
	$Sprite2D.set_modulate(Color(color, max(color.a - wasted_alpha_delta * delta, 0)))

# for debugging
func mark_at(pos: Vector2, clr: Color):
	var marker = preload("res://marker.tscn").instantiate()
	get_parent().add_child(marker)
	marker.modulate = clr
	marker.global_position = pos


func _to_string():
	return "projecile at %s" % str(global_position)
