class_name Tower extends StaticBody2D

const kind = "Tower"

enum State { PLACEHOLDER, BUILDING, READY }

var master: Player
var operator: Unit # a builder or an archer
var enemies_in_range: Array[Unit] = []

var projectile_prefab = preload("res://projectiles/projectile.tscn")

@export var state: State = State.PLACEHOLDER
@export var arc_height: float = 100
@export var max_charges: int = 3
@export var recharge_cooldown_val: float = 4
@export var attack_cooldown_val: float = 0.75
@export var attack_strength: float = 50

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
	
	if !enemies_in_range.is_empty() && attack_cooldown <= 0 && charges > 0:
		launch_projectile()

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


func launch_projectile():
	var a_target = enemies_in_range[0]
	var projectile: Projectile = projectile_prefab.instantiate()
	var launch_at = global_position
	launch_at.y -= 100 # shooting from the top # TODO: add marker
	projectile.global_position = launch_at
	projectile.target = a_target
	projectile.attack_strength = attack_strength
	print(getId() + " attack >> " + str(a_target))
	get_parent().add_child(projectile)
	#var cur_distance_to_target = attacker.global_position.distance_to(target.global_position)
	var predicted_target_pos = a_target.get_pos_after(1) # TODO: fix 
	projectile.launch(self, predicted_target_pos)
	charges -= 1
	attack_cooldown = attack_cooldown_val
	if recharge_cooldown == 0:
		recharge_cooldown = recharge_cooldown_val

func set_operator(unit: Unit):
	if unit != null:
		operator = unit
	else:
		state = State.PLACEHOLDER
		missing_operator.emit(self)
		operator = null


func is_builder_in_place(unit: Unit) -> bool:
	return unit != null && $BuilderArea.get_overlapping_bodies().has(unit)


func _on_area_2d_body_entered(target):
	if Util.is_attackable_enemy(self, target):
		print(getId() + " i see >> " + str(target))
		enemies_in_range.append(target)


func _on_area_2d_body_exited(body):
	if Util.get_kind(body_exited) == "Unit":
		enemies_in_range.erase(body)

func getId() -> String:
	return "tower@" + get_pid()

func get_pid():
	if master == null:
		return "%"
	return master.pid

func _to_string():
	return getId() + " at " + str(position)

func _on_builder_area_body_entered(body):
	if body != operator || state != State.PLACEHOLDER:
		return
	print(getId() + " builder arrived")
