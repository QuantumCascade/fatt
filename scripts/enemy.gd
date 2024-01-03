class_name Enemy
extends Node

## Base class for AI opponent to manage creeps


@export var spawn_queue: Array[String] = []


func _physics_process(_delta: float):
	if not spawn_queue.is_empty() \
			&& spawn_area().get_overlapping_bodies().is_empty():
		var mob_name_to_spawn: String = spawn_queue.pop_front()
		var a_mob_stats: MobStats = GameStats.get_mob_stats(mob_name_to_spawn)
		if a_mob_stats:
			spawn_mob(a_mob_stats)


func spawn_mob(mob_stats: MobStats):
	var mob: Mob = mob_stats.resource.instantiate() as Mob
	mob.add_to_group("enemy_mobs")
	mob.global_position = spawn_area().global_position
	get_parent().add_child(mob)
	mob.setup(mob_stats)
	print("spawned %s at %s" % [mob_stats.name, mob.global_position])


func spawn_area() -> Area2D:
	return get_tree().get_first_node_in_group("enemy_spawn_area") as Area2D
