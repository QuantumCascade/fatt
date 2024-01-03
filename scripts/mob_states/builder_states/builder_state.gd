class_name BuilderState
extends MobState

var builder: Builder

func setup(an_actor: Node):
	super.setup(an_actor)
	assert(an_actor is Builder)
	builder = an_actor as Builder


func _spawn_area() -> PlayerSpawnArea:
	return get_tree().get_first_node_in_group("player_spawn_area") as PlayerSpawnArea
