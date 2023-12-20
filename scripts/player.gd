class_name Player
extends Node2D


signal tower_collision_changed


var stats: PlayerStats = PlayerStats.new()

var spawn_queue: Array[String] = []


func _physics_process(_delta: float):
	
	if not spawn_queue.is_empty() && stats.population > 0 \
			&& spawn_area().get_overlapping_bodies().is_empty():
		var mob_name_to_spawn: String = spawn_queue.pop_front()
		for mob_stats in GameStats.mob_stats:
			if mob_stats.name == mob_name_to_spawn:
				if mob_stats.cost <= stats.spawn_materials:
					spawn_mob(mob_stats)


func castle() -> Castle:
	return get_tree().get_first_node_in_group("castle") as Castle


func build_tower(tower_stats_id: int, pos: Vector2):
	for tower_stats in GameStats.tower_stats:
		if tower_stats.id == tower_stats_id:
			if tower_stats.cost > stats.building_materials:
				print("err: cannot build tower %s - not enough materials: %s" % \
					[tower_stats_id, stats.building_materials])
				return
			print("Paid for %s tower: %s" % [tower_stats.name, tower_stats.cost])
			stats.building_materials -= tower_stats.cost
			var tower: Tower = preload("res://scenes/tower.tscn").instantiate() as Tower
			tower.global_position = pos
			get_parent().add_child(tower)
			tower.setup(tower_stats.clone())
			tower.add_to_group("towers")
			tower.set_new_state(Tower.TowerState.PLACEHOLDER)
			tower.tower_collision_changed.connect(_on_tower_collision_changed)
			spawn_queue.append("builder")


func _on_tower_collision_changed(tower: Tower):
	tower_collision_changed.emit(tower)


## Check if enough resources and population and spawn area before calling this
func spawn_mob(mob_stats: MobStats):
	var mob: Mob = mob_stats.resource.instantiate() as Mob
	mob.add_to_group("player_mobs")
	mob.global_position = spawn_area().global_position
	stats.spawn_materials -= mob_stats.cost
	stats.population -= 1
	get_parent().add_child(mob)
	mob.init_from_stats(mob_stats)
	print("spawned %s at %s" % [mob_stats.name, mob.global_position])


func unspawn(mob: Mob):
	print("unspawn %s" % mob)
	stats.population += 1
	mob.queue_free()


func spawn_area() -> SpawnArea:
	return get_tree().get_first_node_in_group("player_spawn_area") as SpawnArea
