class_name Tower extends StaticBody2D

const kind = "Tower"

enum State { PLACEHOLDER, BUILDING, READY }

var master: Player
var pid: String = "?"
var operator: Unit # a builder or an archer
var enemies_in_range: Array[Unit] = []

@export var state: State = State.PLACEHOLDER

@export var arc_height: float = 30.0
@export var max_charges: int = 2
@export var recharge_cooldown_val: float = 3
@export var attack_cooldown_val: float = 0.75
@export var attack_strength: float = 75

@onready var charges: int = max_charges
@onready var recharge_cooldown: float = recharge_cooldown_val
@onready var attack_cooldown: float = attack_cooldown_val

@export var building_speed = 5
@export var max_hp: float = 100
@onready var hp: float = 0

@onready var orig_modulate: Color = modulate

signal missing_operator
signal operator_inside_tower

func _physics_process(delta: float):
	
	if state == State.PLACEHOLDER && is_builder_in_place(operator) && operator.state == Unit.State.BUILDING:
		print(getId() + " switch to building state")
		state = State.BUILDING
	elif state == State.BUILDING && !is_builder_in_place(operator):
		print_debug(getId() + " builder left")
		state = State.PLACEHOLDER
	
	if state == State.PLACEHOLDER:
		if operator == null:
			missing_operator.emit(self)
		return
	
	if state == State.BUILDING:
		process_building(delta)
		return
	
	if state != State.READY:
		return
	
	regen_cooldowns(delta)
	
	var attackable_enemies: Array = $AttackArea.get_overlapping_areas()\
		.map(get_area_body)\
		.filter(func(b): return Util.is_attackable_enemy(self, b))
	enemies_in_range.clear()
	enemies_in_range.append_array(attackable_enemies)
	
	if !enemies_in_range.is_empty() && attack_cooldown <= 0 && charges > 0:
		launch_projectile(enemies_in_range[0])

# do not collide when tower does not exist yet
func shadow():
	state = State.PLACEHOLDER
	$Sprite2D.modulate = Color(orig_modulate.darkened(0.8), 0.5)
	$CollisionShape2D.disabled = true
	$NavigationObstacle2D.avoidance_enabled = false


func process_building(delta: float):
	hp = min(hp + building_speed * delta, max_hp)
	$ProgressBar.value = hp
	if hp >= max_hp:
		building_finished()

func building_finished():
	state = State.READY
	$ProgressBar.hide()
	operator_inside_tower.emit(operator)
	operator.erase_from_parents()
	print(getId() + " operator inside")
	$Sprite2D.modulate = orig_modulate
	$CollisionShape2D.disabled = false
	$NavigationObstacle2D.avoidance_enabled = true


func regen_cooldowns(delta: float):
	if attack_cooldown > 0:
		attack_cooldown -= min(attack_cooldown, delta)
	
	if recharge_cooldown > 0:
		recharge_cooldown -= min(recharge_cooldown, delta)
		if recharge_cooldown == 0:
			print(getId() + " Recharged!")
			charges = max_charges


func launch_projectile(a_target: Unit):
	var projectile := preload("res://projectiles/projectile.tscn").instantiate() as Projectile
	add_child(projectile)
	var launch_at = $LaunchMarker.global_position
	projectile.global_position = launch_at
	projectile.target = a_target
	projectile.attack_strength = attack_strength
	projectile.arc_height = arc_height
	# hmmm...
	projectile.arc_height = min(arc_height, position.distance_to(a_target.position))
	print(getId() + " attack >> " + str(a_target))
	#var cur_distance_to_target = attacker.global_position.distance_to(target.global_position)
	var predicted_target_pos = a_target.get_pos_after(0.85) # TODO: fix 
	projectile.launch(self, predicted_target_pos)
	charges -= 1
	attack_cooldown = attack_cooldown_val
	if recharge_cooldown == 0:
		recharge_cooldown = recharge_cooldown_val

func set_master(player: Player):
	self.master = player
	self.pid = player.pid

func set_operator(unit: Unit):
	if unit != null:
		operator = unit
	else:
		state = State.PLACEHOLDER
		missing_operator.emit(self)
		operator = null

func is_builder_in_place(unit: Unit) -> bool:
	return unit != null && get_bodies_in_builder_area().has(unit)

func get_bodies_in_builder_area() -> Array:
	return $BuilderArea.get_overlapping_areas().map(get_area_body)

func get_area_body(area: Area2D):
	return area.get_parent()

func _on_builder_area_area_entered(area: Area2D):
	var body = area.get_parent()
	if body != operator || state != State.PLACEHOLDER:
		return
	print(getId() + " builder arrived")


func _on_attack_area_area_entered(area):
	_on_area_2d_body_entered(area.get_parent())

func _on_area_2d_body_entered(target):
	if Util.is_attackable_enemy(self, target):
		print(getId() + " i see >> " + str(target))
		enemies_in_range.append(target)

func _on_attack_area_area_exited(area):
	_on_attack_area_body_exited(area.get_parent())

func _on_attack_area_body_exited(body_exited):
	if Util.get_kind(body_exited) == "Unit":
		enemies_in_range.erase(body_exited)

func getId() -> String:
	return "tower@" + get_pid()

func get_pid():
	if master == null:
		return pid
	return master.pid

func _to_string():
	return getId() + " at " + str(position)

