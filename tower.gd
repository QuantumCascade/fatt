class_name Tower extends StaticBody2D

const kind = "Tower"

enum State { PLACEHOLDER, BUILDING, READY }

var state: State = State.PLACEHOLDER

var master: Player
var operator: Unit # a builder or an archer

var enemies_in_range: Array[Unit] = []

var projectile_prefab = preload("res://projectiles/projectile.tscn")

var attack_cooldown: float = 0
var attack_cooldown_delta: float = 0.02

var hp: float = 0
var max_hp: float = 100
var building_speed = 5

@onready var orig_modulate: Color = modulate

signal operator_was_killed

func _physics_process(delta: float):
	
	if state == State.PLACEHOLDER && is_builder_in_place(operator) && operator.state != Unit.State.ATTACKING:
		print_debug(getId() + " building process initiated")
		state = State.BUILDING
	elif state == State.BUILDING && !is_builder_in_place(operator):
		print_debug(getId() + " builder left")
		state = State.PLACEHOLDER
	
	if state == State.PLACEHOLDER:
		if operator == null:
			master.call_for_builder(self)
		return
	
	if is_builder_in_place(operator) && operator.state != Unit.State.ATTACKING:
		if state != State.BUILDING:
			print(getId() + " building...")
			state = State.BUILDING
	
	if state == State.BUILDING:
		hp = min(hp + building_speed * delta, max_hp)
		$ProgressBar.value = hp
		if hp == max_hp:
			$ProgressBar.hide()
			state = State.READY
			# hide unit inside tower
			operator.get_parent().remove_child(operator)
			$Sprite2D.modulate = orig_modulate
			$CollisionShape2D.disabled = false
			$NavigationObstacle2D.avoidance_enabled = true
		return
	
	if state != State.READY:
		return

	if attack_cooldown > 0:
		attack_cooldown -= min(attack_cooldown, attack_cooldown_delta)
		if attack_cooldown == 0:
			print(getId() + " Recharged!")
	
	if !enemies_in_range.is_empty() && attack_cooldown <= 0:
		var projectile: Projectile = projectile_prefab.instantiate()
		projectile.global_position = global_position
		projectile.global_position.y = projectile.global_position.y - 100
		projectile.target = enemies_in_range[0]
		print(getId() + " attack >> " + str(projectile.target))
		get_parent().add_child(projectile)
		projectile.launch(self)
		attack_cooldown = 2


func shadow():
	$Sprite2D.modulate = Color(orig_modulate.darkened(0.8), 0.5)
	$CollisionShape2D.disabled = true
	$NavigationObstacle2D.avoidance_enabled = false

func set_operator(unit: Unit):
	if unit != null:
		operator = unit
	else:
		state = State.PLACEHOLDER
		operator_was_killed.emit(self)
		operator = null


func is_builder_in_place(unit: Unit) -> bool:
	return unit != null && $BuilderArea.get_overlapping_bodies().has(unit)


func _on_area_2d_body_entered(target):
	if Util.is_attackable_enemy(self, target):
		print(getId() + " i see >> " + str(target))
		enemies_in_range.append(target)


func _on_area_2d_body_exited(body):
	enemies_in_range.erase(body)

func getId() -> String:
	return "tower@" + master.pid

func get_pid():
	return master.pid

func _to_string():
	return getId() + " at " + str(position)

func _on_builder_area_body_entered(body):
	if body != operator || state != State.PLACEHOLDER:
		return
	print(getId() + " builder arrived")

