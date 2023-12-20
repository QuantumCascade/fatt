class_name SpawnArea
extends Area2D



func _on_body_entered(body):
	if is_in_group("player_spawn_area"):
		if body.is_in_group("player_mobs"):
			var mob: Mob = body as Mob
			if mob.movement_target == global_position:
				var player: Player = get_tree().get_first_node_in_group("player") as Player
				if player:
					player.unspawn(mob)

