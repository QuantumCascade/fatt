class_name Tower
extends Node2D


enum TowerState { PLACEHOLDER, BUILDING, ACTIVE, DESTROYED }

# This signal rebuilds map navigation mesh, so it is quite expensive
signal tower_collision_changed

@export var state: TowerState = TowerState.PLACEHOLDER

var stats: TowerStats = TowerStats.new()

# Example: archers who got inside the tower
var mobs: Array[Mob] = [] 


@onready var sprite: Sprite2D = %Sprite
@onready var static_body: StaticBody2D = %StaticBody
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var construction_site_area = %ConstructionSiteArea


func setup(a_stats: TowerStats):
	stats = a_stats.clone()
	sprite.texture = stats.img
	progress_bar.max_value = stats.building_time
	progress_bar.hide()


func set_new_state(new_state: TowerState):
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


func  _physics_process(_delta: float):
	pass

