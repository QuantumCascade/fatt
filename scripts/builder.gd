class_name Builder
extends Minion


@export var building_target: Tower


func _ready():
	
	# Init Mob common components
	state_machine = %BuilderStateMachine
	steering = %Steering
	nav_agent = %NavAgent
	audible = %Audible
	
	# Init Minion personal components 
	hp_bar = %HpBar
	hitbox = %Hitbox
	sprite = %Sprite
	vision_area = %VisionArea


func setup(new_stats: MobStats):
	stats = new_stats.clone()
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.hp
	state_machine.setup(self)


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


func hiding_in_castle():
	super.hiding_in_castle()
	building_target = null


func _to_string():
	return "builder @ %s" % global_position
