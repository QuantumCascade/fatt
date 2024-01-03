class_name PlayerSpawnArea
extends Area2D


func _on_body_entered(body):
	var minion: Minion = body as Minion
	if not minion:
		return
	if not minion.is_in_group("player_minions"):
		return
	if minion.movement_target == self.global_position:
		minion.movement_target = Vector2()
		var player: Player = get_tree().get_first_node_in_group("player") as Player
		if player:
			player.hide_minion_in_castle(minion)

