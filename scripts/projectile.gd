class_name Projectile
extends Node2D

var gravity: float = 980

#var speed: float = 1
var dmg: float
var accuracy: float = 0.97

var velocity: Vector2 = Vector2.ZERO

var target_mob: Node2D # maybe not a mob?

var from: Vector2 # initial projectile global coordinates
var to: Vector2 # target global coordinates
var disposition: Vector2 # original disposition
var arc_height = 50.0 # parabolic vertex height

var wasted: bool = false # missed target
var stuck: bool = false # attached to target hitbox
var stuckable: bool = true
var active: bool = false # if can do damage - activated when launched

var decay_duration: float = 10 # seconds - to slowly disappear


@onready var dmg_area = %DmgArea


func launch(to_target: Vector2):
	attach_to(get_tree().current_scene)
	velocity = calc_initial_velocity(self.global_position, to_target) 
	print("projectile launched with velocity %s" % velocity)
	
	# fix weird velocity if target is too far
	velocity = velocity.clamp(Vector2(-1000, -1000), Vector2(1000, 1000))
	
	# adjust accuracy
	var miss_prob = 1 - accuracy
	velocity = velocity.rotated(randf_range(-miss_prob, miss_prob))
	
	from = self.global_position
	to = to_target
	disposition = to - from
	active = true


func calc_initial_velocity(p1: Vector2, p2: Vector2) -> Vector2:
	# see: https://www.youtube.com/watch?v=_kA1fbBH4ug
	arc_height = min(p2.y - p1.y - arc_height, -arc_height)
	var displacement: Vector2 = p2 - p1
	var time_up: float = sqrt(-2.0 * arc_height / gravity)
	var time_down: float = sqrt(2.0 * (float(displacement.y) - arc_height) / gravity)
	if is_nan(time_down):
		time_down = 0
	var dx: float = displacement.x / (time_up + time_down)
	var dy: float = -sqrt(-2.0 * gravity * arc_height)
	return Vector2(dx, dy)


func _physics_process(delta: float):
	if wasted || stuck:
		decay_wasted(delta)
		return
	velocity.y += gravity * delta
	position += velocity * delta
	rotation = velocity.angle()
	if position.y - 10 > to.y and velocity.y > 0:
		wasted = true
		deactivate()
		print("missed at %s while target mob at %s" % [global_position, target_mob.global_position])
		print("discrepancy with predicted: %s" % [target_mob.global_position - to])


# cleanup
func _on_timer_timeout():
	queue_free()


func _on_dmg_area_area_entered(hitbox_area: Hitbox):
	if wasted || stuck || not active:
		return
	var mob: Mob = hitbox_area.get_parent()
	print("projectile hit >> %s" % mob)
	mob.take_dmg(dmg)
	if stuckable:
		# this should be cool - stuck into the enemy body ^_^
		stuck = true
		call_deferred("deactivate")
		call_deferred("attach_to", find_attachable(hitbox_area))


func find_attachable(node: Node2D) -> Node2D:
	var a_parent = node.get_parent()
	if not a_parent:
		return node
	var sprite = a_parent.find_child("Sprite")
	if sprite:
		return sprite as Node2D
	return node


# when landed and already did damage
func deactivate():
	dmg_area.monitoring = false
	active = false


func attach_to(node):
	var tmp = global_transform
	reparent(node)
	global_transform = tmp


func decay_wasted(delta: float):
	if modulate.a <= 0:
		print("wipe projectile finally %s" % global_position)
		queue_free()
		return
	modulate.a = max(modulate.a - delta / decay_duration, 0)


func _to_string():
	return "projecile at %s" % global_position
