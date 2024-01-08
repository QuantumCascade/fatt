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


func check_pending_towers():
	if building_target && building_target.stats.building_time > 0:
		return
	var pending_towers: Array[Tower] = []
	for _tower in get_tree().get_nodes_in_group("towers"):
		var tower = _tower as Tower
		if tower.stats.building_time > 0:
			pending_towers.append(tower)
	if not pending_towers.is_empty():
		pending_towers.sort_custom(choose_closest)
		building_target = pending_towers[0]


func in_building_area() -> bool:
	return building_target && %WorkingArea.get_overlapping_areas().has(building_target.construction_site_area)


func hiding_in_castle():
	super.hiding_in_castle()
	building_target = null


func _to_string():
	return "builder @ %s" % global_position
