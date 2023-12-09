class_name Unit extends CharacterBody2D

const kind = "Unit"

enum State { WAITING, WALKING, ATTACKING, BUILDING, DYING, DEAD }

var id: String = "unit"
var master: Player
var party_id: int = -1

@export var movement_speed: float = 100.0
@export var vision_range: float = 150
@export var attack_range: float = 25
@export var attack_strength: float = 50
@export var armor: float = 10
@export var hp: float = 100
@export var max_hp: float = 100

@export var state: State = State.WAITING

var enemy_castle: Castle = null
var general_target: Node2D = null
var gathering_spot: Area2D
var current_target: Node2D = null

# if set then unit is a builder or an archer
var operating_tower: Tower = null 

var decay_alpha_delta: float = 0.001
var particles: Particles

var desired_velocity: Vector2
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var state_label: Label = $StateLabel
@onready var attack_obj: Area2D = $Attack
@onready var vision_obj: Area2D = $Vision

signal killed # hp=0 - play "dying" animation
signal died # dying animation complete
signal decayed # corpse disappeared from the scene

func _ready():
	if master == null:
		#just to debug as a separate scene
		return
	$Attack/AttackRange.shape.radius = attack_range
	$Vision/VisionRange.shape.radius = vision_range
	$HpBar.max_value = hp
	$HpBar.value = hp
	$HpBar.visible = false
	$SpawnSfx.pitch_scale = randf_range(0.5, 1.5)
	$SpawnSfx.play()
	if get_pid() == "a":
		gathering_spot = get_parent().find_child("GatheringSpot1").find_child("Area2D")
	else:
		gathering_spot = get_parent().find_child("GatheringSpot2").find_child("Area2D")

func init_stats(stats: PlayerStats):
	hp = stats.basic_unit_hp
	max_hp = stats.basic_unit_hp
	attack_strength = stats.basic_unit_attack_strength
	armor = stats.basic_unit_armor
	movement_speed = stats.basic_unit_movement_speed

func decay_dead():
	var color: Color = $AnimatedSprite2D.modulate
	if color.a <= 0:
		print(getId() + " decayed finally.")
		decayed.emit()
		queue_free()
		return
	$AnimatedSprite2D.set_modulate(Color(color, color.a - decay_alpha_delta))


func _physics_process(delta: float):
	#updateStateLabel()

	if state == State.DEAD:
		decay_dead()
		return

	if state == State.DYING || state == null:
		return

	if hp / max_hp < 0.15:
		# bleeding 2% per sec
		# TODO: draw blood drops
		hp = max(hp - max_hp * 0.02, 0) * delta
	
	# if unit was killed but not marked as DEAD/DYING
	if hp <= 0:
		killed_switch_to_dying()
		return

	# the unit is alive - let's pick a target
	var visibleTargets = vision_obj.get_overlapping_bodies().filter(is_attackable_enemy)
	var attackableTargets = attack_obj.get_overlapping_bodies().filter(is_attackable_enemy)
	
	if visibleTargets.is_empty():
		choose_where_to_go_when_no_visible_targets()
	elif current_target != null && attackableTargets.has(current_target):
		# the current target is still nearby and can be attacked
		pass
	elif !attackableTargets.is_empty():
		# there is another target close enough - let's attack it
		current_target = attackableTargets[0]
	else:
		# approach visible enemy
		current_target = visibleTargets[0]
	
	# at this point we chose a target
	
	if operating_tower != null && current_target == operating_tower \
		&& operating_tower.is_builder_in_place(self):
		if state != State.BUILDING:
			print(getId() + " busy - building " + str(operating_tower))
			anim.play("idle")
			anim_player.play("idle")
		state = State.BUILDING
	
	if can_attack(current_target):
		if state != State.ATTACKING:
			# switch to attack
			state = State.ATTACKING
			print(getId() + " attacking >> " + str(current_target))
			$SwooshSfx.pitch_scale = randf_range(0.5, 1.5)
			$SwooshSfx.play()
		attack(delta)
	elif state == State.BUILDING:
		pass
	elif current_target != null:
		# the target is not in attack range - let's walk then
		state = State.WALKING
		navigate()
	else:
		anim.play("idle")
		anim_player.play("idle")
		state = State.WAITING
	
	if state != State.WALKING:
		desired_velocity = Vector2.ZERO

func choose_where_to_go_when_no_visible_targets():
	if operating_tower != null:
		if current_target != operating_tower:
			print(getId() + " going to build " + str(operating_tower))
		current_target = operating_tower
	elif is_goto_gathering():
		if current_target != gathering_spot:
			print(getId() + " gathering with pals at " + str(gathering_spot.position))
		current_target = gathering_spot
	elif general_target != null:
		current_target = general_target
	elif current_target != enemy_castle && enemy_castle != null && enemy_castle.body.hp > 0:
		current_target = enemy_castle
		print(getId() + " marching to the enemy castle!")
	elif enemy_castle != null && enemy_castle.body.hp <= 0 && current_target != null:
		print(getId() + " we're done here - let's have rest")
		current_target = null
	set_movement_target(current_target)


func is_goto_gathering() -> bool:
	if gathering_spot == null:
		return false
	var party_size = gathering_spot.get_overlapping_bodies().size()
	if party_size >= master.stats.gathering_party_count:
		gathering_spot = null
		print(getId() + " let's go together comrades!")
		master.stats.next_party_id = party_id + 1
		return false
	if !master.has_spawn_potential():
		gathering_spot = null
		if master.pid == "a":
			# let's give free buff to last mobs
			attack_strength *= 1.5
			print(getId() + " we are the last hope (buffed) - attack!")
		else:
			print(getId() + " we are the last ")
		master.stats.next_party_id = party_id + 1
		return false
	if party_id < 0:
		print(str(master.get_spawn_potential()) + " mana in stocks - waiting for party " + _to_string())
		party_id = master.stats.next_party_id
	return true

func killed_switch_to_dying():
	state = State.DYING
	anim.play("die")
	anim_player.play("die")
	nav_agent.avoidance_enabled = false
	nav_agent.radius = 0
	master.on_mob_killed(self)
	$DyingSfx.pitch_scale = randf_range(0.5, 1.5)
	$DyingSfx.play()
	$HpBar.visible = false
	killed.emit(self)
	if operating_tower != null:
		operating_tower.set_operator(null)


func is_first_closer_than_second(first: Node2D, second: Node2D) -> bool:
	return position.distance_squared_to(first.position) < position.distance_squared_to(second.position)

func set_movement_target(movement_target: Node2D):
	if movement_target == null:
		current_target = null
		return
	if current_target != movement_target:
		current_target = movement_target
		print(getId() + " going to >> " + str(current_target))
	if nav_agent.target_position != current_target.global_position:
		nav_agent.set_target_position(current_target.global_position)


func receive_dmg(dmg: Dictionary, _attacker: Node) -> void:
	var hp_before = hp
	armor -= min(dmg.armor_dmg, armor)
	hp = max(hp - dmg.dmg, 0)
	print(getId() + " received_dmg=" + str(dmg) \
		+ ", from: " + getId() \
		+ ", armor_left=" + str(armor) \
		+ " ~ hp: " + str(hp_before) + "->" + str(hp))
	$HitHurtSfx.pitch_scale = randf_range(0.5, 1.5)
	$HitHurtSfx.play()
	var hp_perc: float = 1.0 * hp / max_hp
	nav_agent.max_speed = get_movement_speed()
	$HpBar.value = hp
	$HpBar.visible = true
	if hp_perc < 0.25:
		$HpBar.modulate = Color.RED
		movement_speed *= 0.75
	elif hp_perc < 0.5:
		movement_speed *= 0.75
		$HpBar.modulate = Color.YELLOW

func can_attack(target: Node) -> bool:
	return target != null \
		&& attack_obj.get_overlapping_bodies().has(target) \
		&& is_attackable_enemy(target)

func is_attackable_enemy(target: Node) -> bool:
	return Util.is_attackable_enemy(self, target)

func attack(_delta: float):
	var dir = global_position.direction_to(current_target.global_position)
	anim.flip_h = dir.x < 0
	anim.play("attack")
	anim_player.play("attack")
	$Sprite2D.flip_h = dir.x < 0
	if dir.y > 0:
		state_label.position = abs(state_label.position)
	else:
		state_label.position = abs(state_label.position) * -1

func use_alt_anim():
	$Sprite2D.hide()
	$AnimatedSprite2D.show()

# for animated sprite
func animation_complete():
	if anim.animation == "attack":
		after_attack_animation()
	if anim.animation == "die":
		after_die_animation()

func _on_animation_player_animation_finished(anim_name: String):
	if anim_name == "attack":
		after_attack_animation()
	elif anim_name == "die":
		after_die_animation()

func after_attack_animation():
	if state == State.ATTACKING:
		if can_attack(current_target):
			var dmg = Util.calc_dmg(self, current_target)
			current_target.receive_dmg(dmg, self)
			if current_target.hp <= 0:
				current_target = null
				state = State.WAITING
		else:
			print(getId() + " attack missed")

func after_die_animation():
	state = State.DEAD
	$CollisionShape2D.disabled = true
	died.emit(self)
	print(getId() + " died")

func navigate():
	if nav_agent.is_navigation_finished():
		state = State.WAITING
		anim.play("idle")
		anim_player.play("idle")
		desired_velocity = Vector2.ZERO
		return
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	desired_velocity = position.direction_to(next_path_position) * get_movement_speed()
	nav_agent.set_velocity(desired_velocity)
	anim.play("walk")
	anim_player.play("walk")
	anim.flip_h = self.velocity.x < 0
	$Sprite2D.flip_h = self.velocity.x < 0

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if state == State.WALKING:
		velocity = safe_velocity
		move_and_slide()

func _on_nav_timer_timeout():
	# recalculate path from time to time
	set_movement_target(current_target)
	#add_marker(get_pos_after(1), Color.WHITE)

func add_marker(pos: Vector2, clr: Color):
	var m = preload("res://marker.tscn").instantiate()
	m.global_position = pos
	m.modulate = clr
	get_parent().add_child(m)

func predict_pos_after_walking(distance: float) -> Vector2:
	var t = distance / get_movement_speed()
	return get_pos_after(t)

func get_movement_speed() -> float:
	return movement_speed

func get_pos_after(delta: float) -> Vector2:
	return global_position + desired_velocity * delta

func updateStateLabel():
	state_label.text = str(state) + " | " + str(hp) + "hp"


func apply_color_mod(color_mod: Color):
	$AnimatedSprite2D.modulate = $AnimatedSprite2D.modulate + color_mod

func erase_from_parents():
	print(getId() + " hiding")
	if master != null:
		master.mobs.erase(self)
		if master.main_scene != null:
			master.main_scene.mobs.erase(self)
	$NavTimer.stop()
	get_parent().remove_child(self)


func get_pid():
	if master == null:
		return "?"
	return master.pid

func getId() -> String:
	return id
	
func _on_attack_body_entered(body):
	if can_attack(body):
		print(getId() + " attackable >> " + str(body))
	
func _on_vision_body_entered(body):
	if can_attack(body):
		print(getId() + " visible >> " + str(body))

func _to_string():
	return getId() + "|" + str(hp) + "hp|party^" + str(party_id) + "|" + State.keys()[state]

