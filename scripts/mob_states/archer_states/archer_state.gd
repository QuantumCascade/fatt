class_name ArcherState
extends MobState

var archer: Archer

func setup(an_actor: Node):
	super.setup(an_actor)
	assert(an_actor is Archer)
	archer = an_actor as Archer


func _spawn_area() -> PlayerSpawnArea:
	return get_tree().get_first_node_in_group("player_spawn_area") as PlayerSpawnArea
