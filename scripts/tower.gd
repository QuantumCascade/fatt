class_name Tower
extends Node2D


enum TowerState { PLACEHOLDER, BUILDING, ACTIVE, DESTROYED }

# This signal rebuilds map navigation mesh, so it is quite expensive
signal tower_collision_changed

@export var state: TowerState = TowerState.PLACEHOLDER

var stats: TowerStats = TowerStats.new()

# Example: archers who got inside the tower
var minions: Array[Minion] = [] 

# These minions were assigned to this tower but haven't arrived yet
var minions_on_the_way_to_tower: Array[Minion] = [] 

var charges: int = 0
var cooldowns: Array[float] = []
var between_atk_cooldown: float

@onready var sprite: Sprite2D = %Sprite
@onready var static_body: StaticBody2D = %StaticBody
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var construction_site_area: Area2D = %ConstructionSiteArea
@onready var launch_marker: Marker2D = %LaunchMarker
@onready var attack_area: AttackArea = %AttackArea
@onready var attack_range: CollisionShape2D = %AttackRange
@onready var tower_upper_buttons: TowerUpperButtons = %TowerUpperButtons
@onready var audio_player: AudioStreamPlayer2D = %AudioPlayer
@onready var loading_area: Area2D = %LoadingArea
@onready var loading_zone: CollisionPolygon2D = %LoadingZone


func setup(new_stats: TowerStats):
	stats = new_stats.clone()
	sprite.texture = stats.img
	attack_range.shape.radius = stats.atk_range
	progress_bar.max_value = stats.building_time
	progress_bar.hide()



func  _physics_process(delta: float):

	check_upper_buttons()

	if state != TowerState.ACTIVE:
		return
	
	regen_cooldowns(delta)
	
	if charges > 0 && between_atk_cooldown == 0 && attack_area.has_overlapping_areas():
		var mob: Mob = attack_area.get_overlapping_areas()[0].get_parent() as Mob
		launch_projectile(mob)


func check_upper_buttons():
	var assigned_minions_count: int = minions.size() + minions_on_the_way_to_tower.size()
	var buttons_count: int = tower_upper_buttons.get_buttons().size()
	if buttons_count > stats.max_minions_in_tower - assigned_minions_count:
		print("%s detected too much buttons: %s/(%s - %s)" % [self, buttons_count, stats.max_minions_in_tower, assigned_minions_count])
		tower_upper_buttons.remove_all_buttons()
	if state != TowerState.ACTIVE or stats.max_minions_in_tower == 0:
		if tower_upper_buttons.visible:
			tower_upper_buttons.visible = false
		return
	if assigned_minions_count >= stats.max_minions_in_tower:
		if tower_upper_buttons.visible:
			print("%s filled all slots" % self)
			tower_upper_buttons.visible = false
		return
	if not tower_upper_buttons.visible:
		print("%s available slots" % self)
		tower_upper_buttons.visible = true
		var hire_minion_button: TowerUpperButton = preload("res://scenes/tower_upper_button.tscn").instantiate()
		tower_upper_buttons.add_button(hire_minion_button)
		if buttons_count > 0 || assigned_minions_count > 0:
			hire_minion_button.border_alerting_color_shift = Vector3(2, 0, 2)
		else:
			hire_minion_button.border_alerting_color_shift = Vector3(0, 2, 2)
		hire_minion_button.button_pressed.connect(_on_hire_minion_button_pressed)


func _on_hire_minion_button_pressed(_button):
	var player: Player = _player()
	if not player or not player.check_if_can_hire_minion(stats.wanted_minion_in_tower):
		return
	var hired_minion: Minion = player.hire_minion(stats.wanted_minion_in_tower)
	if not hired_minion:
		print("err: %s was not hired" % stats.wanted_minion_in_tower)
		return
	print("assign %s to %s" % [self, hired_minion])
	minions_on_the_way_to_tower.append(hired_minion)
	hired_minion.assigned_tower = self
	tower_upper_buttons.remove_all_buttons()


func set_new_state(new_state: TowerState):
	print("%s: %s -> %s" % [self, state, new_state])
	state = new_state
	match state:
		TowerState.PLACEHOLDER:
			progress_bar.hide()
			progress_bar.max_value = stats.building_time
			progress_bar.value = 0
			sprite.modulate.a = 0.5
			if static_body.collision_layer != 0:
				static_body.collision_layer = 0
				tower_collision_changed.emit(self)
		TowerState.BUILDING:
			progress_bar.show()
			if static_body.collision_layer != 1:
				static_body.collision_layer = 1
				tower_collision_changed.emit(self)
		TowerState.ACTIVE:
			progress_bar.hide()
			sprite.modulate.a = 1
			if static_body.collision_layer != 1:
				static_body.collision_layer = 1
				tower_collision_changed.emit(self)


# A builder should call this during physics process if he is in the construction zone
func process_building(delta: float):
	stats.building_time = max(stats.building_time - delta, 0)
	progress_bar.value = progress_bar.max_value - stats.building_time
	var perc: float = progress_bar.value / progress_bar.max_value
	sprite.modulate.a = 0.5 + 0.5 * perc
	if state == TowerState.PLACEHOLDER:
		set_new_state(TowerState.BUILDING)
	if stats.building_time == 0:
		set_new_state(TowerState.ACTIVE)


func launch_projectile(a_target: Mob):
	var projectile: Projectile = preload("res://scenes/projectile.tscn").instantiate() as Projectile
	add_child(projectile)
	var launch_at = launch_marker.global_position
	projectile.global_position = launch_at
	projectile.dmg = stats.dmg
	#projectile.speed = stats.projectile_speed
	projectile.arc_height = stats.arc_height
	# hmmm...
	projectile.arc_height = min(stats.arc_height, position.distance_to(a_target.position))
	var time_to_hit: float = 0.65 # TODO: fix 
	var predicted_target_pos = a_target.get_pos_after(time_to_hit) 
	var predicted_hitbox_pos = predicted_target_pos + a_target.hitbox.position
	print("tower attack >> %s with hitbox at %s" % [predicted_target_pos, predicted_hitbox_pos])
	projectile.target_mob = a_target
	projectile.launch(predicted_hitbox_pos)
	#Debug.draw_marker_at(predicted_hitbox_pos, get_tree())
	charges -= 1
	between_atk_cooldown = stats.between_atk_cooldown
	cooldowns.append(1.0 / stats.atk_spd)


func regen_cooldowns(delta: float):
	between_atk_cooldown = max(between_atk_cooldown - delta, 0)
	for i in range(cooldowns.size()):
		var cooldown: float = max(cooldowns[i] - delta, 0)
		cooldowns[i] = cooldown
		if cooldown == 0:
			charges += 1
			print("%s recharged - stack: %s" % [self, charges])
	cooldowns = cooldowns.filter(func(cooldown: float) -> bool: return cooldown > 0)


func is_minion_assigned(candidate: Minion) -> bool:
	if minions_on_the_way_to_tower.is_empty():
		return false
	check_minions_on_the_way_to_tower()
	return minions_on_the_way_to_tower.has(candidate)


func check_minions_on_the_way_to_tower():
	var excess: int = minions.size() + minions_on_the_way_to_tower.size() - stats.max_minions_in_tower
	if excess <= 0:
		return
	for i in range(excess):
		if not minions_on_the_way_to_tower.is_empty():
			var excluded: Minion = minions_on_the_way_to_tower.pop_back()
			print("%s overflow - excluded candidate: %s" % [self, excluded])


func load_minion(minion: Minion):
	audio_player.stream = preload("res://assets/sounds/door-shut-01.ogg")
	audio_player.play()
	minions.append(minion)
	minion.get_parent().remove_child(minion)
	minion.remove_from_group("player_minions")
	print("%s got inside %s" % [minion, self])
	tower_upper_buttons.remove_all_buttons()
	charges += 1


func get_nearest_loading_point(pos: Vector2) -> Vector2:
	var dist_sq: float = 999999999
	var selected_point = loading_area.global_position
	for point: Vector2 in loading_zone.polygon:
		var global_point = point + loading_zone.global_position
		if pos.distance_squared_to(global_point) < dist_sq:
			selected_point = global_point
	return selected_point

func is_in_loading_zone(pos: Vector2) -> bool:
	for point: Vector2 in loading_zone.polygon:
		var global_point = point + loading_zone.global_position
		if global_point == pos:
			return true
	return false

func _player() -> Player:
	return get_tree().get_first_node_in_group("player") as Player


func _to_string():
	return "tower @ %s bt=%s" % [global_position, stats.building_time]
