class_name Archer
extends Minion

const ArcHeight: float = 15

@export var assigned_tower: Tower


var enemy_to_attack: Node2D


@onready var attack_area: AttackArea = %AttackArea
@onready var launch_marker: Marker2D = %LaunchMarker


func _ready():
	
	# Init Mob common components
	state_machine = %ArcherStateMachine
	steering = %Steering
	nav_agent = %NavAgent
	audible = %Audible
	
	# Init Minion personal components 
	hp_bar = %HpBar
	hitbox = %Hitbox
	sprite = %Sprite
	vision_area = %VisionArea


func setup(new_stats: MobStats):
	super.setup(new_stats)
	#if stats.atk_range:
		#attack_area.radius = stats.atk_range
	#vision_area.radius = stats.vision_range
	sprite.attack_animation_performed.connect(_on_attack_animation_performed)
	sprite.attack_animation_complete.connect(_on_attack_animation_complete)


func play_anim(anim_name: String):
	sprite.play(anim_name)


func check_enemies_in_attack_area() -> bool:
	if attack_area.get_overlapping_areas().is_empty():
		return false
	var enemy_hitbox: Hitbox = attack_area.get_overlapping_areas()[0] as Hitbox
	enemy_to_attack = enemy_hitbox.get_parent()
	if not enemy_to_attack:
		return false
	return true


func check_visible_enemies() -> bool:
	if vision_area.get_overlapping_areas().is_empty():
		return false
	var enemy_hitbox: Hitbox = vision_area.get_overlapping_areas()[0] as Hitbox
	enemy_to_attack = enemy_hitbox.get_parent()
	if not enemy_to_attack:
		return false
	return true


func check_assigned_tower() -> bool:
	if assigned_tower and assigned_tower.state == Tower.TowerState.ACTIVE:
		return true
	for tower: Tower in get_tree().get_nodes_in_group("towers"):
		if tower.is_minion_assigned(self) and tower.state == Tower.TowerState.ACTIVE:
			assigned_tower = tower
			return true
	return false


func is_in_assigned_tower_area() -> bool:
	if not assigned_tower: 
		return false
	return assigned_tower.loading_area.get_overlapping_bodies().has(self)
	#return assigned_tower.loading_area.get_overlapping_areas().has(self.hitbox)


func _on_attack_animation_performed():
	launch_projectile(enemy_to_attack)
	pass


func _on_attack_animation_complete():
	pass


func launch_projectile(a_target: Node2D):
	var projectile: Projectile = preload("res://scenes/projectile.tscn").instantiate() as Projectile
	add_child(projectile)
	var launch_at = launch_marker.global_position
	projectile.global_position = launch_at
	projectile.dmg = stats.dmg
	#projectile.speed = stats.projectile_speed
	projectile.arc_height = Archer.ArcHeight
	# hmmm...
	projectile.arc_height = min(Archer.ArcHeight, position.distance_to(a_target.position))
	var time_to_hit: float = 0.65 # TODO: fix 
	var predicted_target_pos = a_target.get_pos_after(time_to_hit) 
	var predicted_hitbox_pos = predicted_target_pos + a_target.hitbox.position
	print("%s attack >> %s with hitbox at %s" % [self, predicted_target_pos, predicted_hitbox_pos])
	projectile.target_mob = a_target
	projectile.launch(predicted_hitbox_pos)
	#Debug.draw_marker_at(predicted_hitbox_pos, get_tree())


# Returns true if body is in attack area and has hitbox
func is_attackable(body: Node) -> bool:
	return body and attack_area.get_overlapping_areas().has(body.hitbox)


func hiding_in_castle():
	super.hiding_in_castle()
	enemy_to_attack = null


func flip_to(target: Vector2):
	super.flip_to(target)
	if target.x < 0:
		launch_marker.position.x = -abs(launch_marker.position.x)
	else:
		launch_marker.position.x = abs(launch_marker.position.x)


func _to_string():
	return "archer @ %s" % global_position
