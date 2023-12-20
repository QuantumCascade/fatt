class_name Builder
extends Mob

@onready var anim_player = %AnimationPlayer
@onready var hp_bar: HpBar = %HpBar
@onready var hitbox: Hitbox = %Hitbox
@onready var state_machine: StateMachine = %StateMachine
@onready var nav_agent: NavAgent = %NavAgent
@onready var steering: Steering = %Steering
@onready var sprite: Sprite2D = %Sprite

@export var building_target: Tower

var building_area_dist: float = 50


func _ready():
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.hp
	state_machine.setup(self)

func get_nav_agent() -> NavAgent:
	return nav_agent

func get_steering() -> Steering:
	return steering

func check_pending_towers():
	if building_target && building_target.stats.building_time > 0:
		return
	for _tower in get_tree().get_nodes_in_group("towers"):
		var tower = _tower as Tower
		if tower.stats.building_time > 0:
			building_target = tower
			return


func take_dmg(dmg: float):
	super.take_dmg(dmg)
	hp_bar.value = stats.hp


func in_building_area() -> bool:
	return building_target && %WorkingArea.get_overlapping_areas().has(building_target.construction_site_area)


func _on_nav_agent_velocity_computed(safe_velocity: Vector2):
	super._on_nav_agent_velocity_computed(safe_velocity)
