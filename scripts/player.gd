class_name Player
extends Node2D


signal tower_collision_changed


var stats: PlayerStats = PlayerStats.new()

# Detacher from the scene tree
var minions_in_castle: Array[Minion] = []


func _ready():
	create_initial_minions(stats.init_minions)


func create_initial_minions(init_minions: Dictionary):
	for init_minion_name: String in init_minions:
		var init_count: int = stats.init_minions.get(init_minion_name) as int
		var mob_stats: MobStats = GameStats.get_mob_stats(init_minion_name)
		print("Init with %s %s(s) in castle" % [init_count, init_minion_name])
		for i in range(init_count):
			var minion: Minion = mob_stats.resource.instantiate() as Minion
			add_child(minion)
			minion.setup(mob_stats)
			hide_minion_in_castle(minion)


func _physics_process(delta: float):
	
	check_towers_for_builders()
	
	check_assigned_towers()
	
	gather_resources(delta)


func gather_resources(delta: float):
	stats.building_materials += delta * stats.building_materials_mining_speed
	stats.gold += delta * stats.gold_mining_speed


func hire_minion(wanted_minion_name: String) -> Minion:
	var wanted_minion_stats: MobStats = check_if_can_hire_minion(wanted_minion_name)
	if not wanted_minion_stats:
		print("err: cannot hire unknown minion: %s" % [wanted_minion_name])
		return null
	if stats.gold < wanted_minion_stats.cost:
		print("cannot hire %s: not enough gold: %s/%s" % [wanted_minion_name, stats.gold, wanted_minion_stats.cost])
		return null
	if stats.population < 1:
		print("cannot hire %s: not enough population" % [wanted_minion_name])
		return null
	stats.gold -= wanted_minion_stats.cost
	stats.population -= 1
	var minion: Minion = wanted_minion_stats.resource.instantiate() as Minion
	print("hired %s | population left: %s" % [minion, stats.population])
	add_child(minion)
	minion.setup(wanted_minion_stats)
	hide_minion_in_castle(minion)
	return minion


func check_if_can_hire_minion(wanted_minion_name: String) -> MobStats:
	var wanted_minion_stats: MobStats = GameStats.get_mob_stats(wanted_minion_name)
	if not wanted_minion_stats:
		print("err: unknown minion %s" % wanted_minion_name)
		return null
	if wanted_minion_stats.cost > stats.gold:
		#print("not enough gold to hire minion %s" % wanted_minion_name)
		return null
	if stats.population < 1:
		#print("not enough population to hire minion %s" % wanted_minion_name)
		return null
	return wanted_minion_stats


func release_minion_from_castle(wanted_minion_name: String) -> Minion:
	var minion_to_release: Minion = check_minion_in_castle(wanted_minion_name)
	if not minion_to_release:
		print("err: can't find in castle wanted: %s" % minion_to_release)
		return null
	if not is_spawn_area_available():
		return null
	minions_in_castle.erase(minion_to_release)
	return summon_minion(minion_to_release)


func release_the_minion_from_castle(minion: Minion):
	if not minions_in_castle.has(minion):
		return
	minions_in_castle.erase(minion)
	summon_minion(minion)


func check_minion_in_castle(wanted_minion_name: String) -> Minion:
	for minion_in_castle: Minion in minions_in_castle:
		if minion_in_castle.stats.name == wanted_minion_name:
			return minion_in_castle
	return null


# Release a builder from castle if have anything to build
func check_towers_for_builders():
	for tower: Tower in get_tree().get_nodes_in_group("towers"):
		if tower.stats.building_time <= 0:
			continue
		if not check_minion_in_castle("builder"):
			return
		if not is_spawn_area_available():
			return
		print("relaseing builder for tower: %s" % tower)
		release_minion_from_castle("builder")


# Release a minion from castle if it has assigned tower
func check_assigned_towers():
	for minion in minions_in_castle:
		if minion.get("assigned_tower") and is_spawn_area_available():
			release_the_minion_from_castle(minion)
			return


func build_tower(tower_stats_id: int, pos: Vector2):
	var tower_stats: TowerStats = GameStats.get_tower_stats(tower_stats_id)
	if not tower_stats:
		print("err: failed to find tower stats with id=%s" % tower_stats_id)
		return
	if tower_stats.cost > stats.building_materials:
		print("err: cannot build tower %s - not enough materials: %s" % \
			[tower_stats_id, stats.building_materials])
		return
	print("Paid for %s tower: %s" % [tower_stats.name, tower_stats.cost])
	stats.building_materials -= tower_stats.cost
	var tower: Tower = load("res://scenes/tower.tscn").instantiate() as Tower
	tower.global_position = pos
	get_parent().add_child(tower)
	tower.setup(tower_stats)
	tower.add_to_group("towers")
	tower.set_new_state(Tower.TowerState.PLACEHOLDER)
	tower.tower_collision_changed.connect(_on_tower_collision_changed)


func _on_tower_collision_changed(tower: Tower):
	tower_collision_changed.emit(tower)


func summon_minion(minion: Minion):
	minion.add_to_group("player_minions")
	minion.global_position = spawn_area().global_position
	get_parent().add_child(minion)
	print("summoned %s" % [minion])


func hide_minion_in_castle(minion: Minion):
	print("hiding in castle %s" % minion)
	minion.hiding_in_castle()
	minions_in_castle.append(minion)
	minion.get_parent().remove_child(minion)
	minion.remove_from_group("player_minions")


func is_spawn_area_available() -> bool:
	return spawn_area().get_overlapping_bodies().is_empty()


func spawn_area() -> PlayerSpawnArea:
	return get_tree().get_first_node_in_group("player_spawn_area") as PlayerSpawnArea

func castle() -> Castle:
	return get_tree().get_first_node_in_group("castle") as Castle


func calc_minions(wanted_minion_name: String) -> int:
	var in_castle: int = minions_in_castle \
		.map(func(m: Minion): return 1 if m.stats.name == wanted_minion_name else 0) \
		.reduce(sum, 0)
	var in_field: int = get_tree().get_nodes_in_group("player_minions") \
		.map(func(m: Minion): return 1 if m.stats.name == wanted_minion_name else 0) \
		.reduce(sum, 0)
	return in_castle + in_field

func sum(n: int, accum: int) -> int:
	return n + accum
