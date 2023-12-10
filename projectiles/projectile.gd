class_name Projectile extends Area2D

const kind: String = "Projectile"

var attack_strength: float = 50.0
var accuracy: float = 0.95

var velocity: Vector2 = Vector2.ZERO

var attacker: Node2D # object launched this projectile
var pid: String = "?" # player id of attacker
var target: Unit # intended target

var from: Vector2 # global coordinates
var to: Vector2 # global coordinates
var vertex: Vector2 # parabolic vertex
var dir: Vector2 # original direction - normalized vector
var arc_height = 50.0 # parabolic vertex height
var wasted: bool = false # missed target
var is_stuck: bool = false # attached to target body or hitbox
var is_stuckable: bool = true
var active: bool = false # can do damage - activated when launched

var wasted_alpha_delta: float = 0.15 # to slowly disappear

func calc_initial_velocity(p1: Vector2, p2: Vector2) -> Vector2:
	# see: https://www.youtube.com/watch?v=_kA1fbBH4ug
	arc_height = min(p2.y - p1.y - arc_height, -arc_height)
	var displacement: Vector2 = p2 - p1
	var time_up: float = sqrt(-2.0 * arc_height / float(gravity))
	var time_down: float = sqrt(2.0 * (float(displacement.y) - arc_height) / float(gravity))
	if is_nan(time_down):
		time_down = 0
	var dx: float = displacement.x / (time_up + time_down)
	var dy: float = -sqrt(-2.0 * float(gravity) * arc_height)
	return Vector2(dx, dy)

func launch(subj: Node2D, to_target: Vector2):
	self.attacker = subj
	self.pid = Util.gets("pid", attacker)
	
	gravity = 980.0
	attach_to(get_tree().current_scene)
	velocity = calc_initial_velocity(self.global_position, to_target) 
	
	# fix weird velocity if target is too far
	velocity = velocity.clamp(Vector2(-1000, -1000), Vector2(1000, 1000))
	
	# adjust accuracy
	var miss_prob = 1 - accuracy
	velocity = velocity.rotated(randf_range(-miss_prob, miss_prob))
	
	from = self.global_position
	to = to_target
	dir = from.direction_to(to)
	active = true


func _physics_process(delta: float):
	if wasted || is_stuck:
		decay_wasted(delta)
		return
	velocity.y += gravity * delta
	position += velocity * delta
	rotation = velocity.angle()


# cleanup
func _on_timer_timeout():
	queue_free()


func _on_area_entered(hitbox_area: Area2D):
	if wasted || is_stuck:
		return
	var body = hitbox_area.get_parent()
	if Util.is_attackable_enemy(attacker, body):
		print("projectile hit >> " + str(body))
		var dmg = Util.calc_dmg(self, body)
		body.receive_dmg(dmg, self)
		if is_stuckable:
			# this should be cool - stuck into the enemy body ^_^
			is_stuck = true
			call_deferred("deactivate")
			call_deferred("attach_to", hitbox_area)

# when landed and already did damage
func deactivate():
	monitoring = false
	monitorable = false
	active = false


func attach_to(node):
	var tmp = global_transform
	reparent(node)
	global_transform = tmp


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


func get_pid():
	return pid

func _to_string():
	return "projecile@%s at %s" % [pid, global_position]
