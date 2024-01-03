class_name MobState
extends State

var mob: Mob

func setup(an_actor: Node):
	super.setup(an_actor)
	assert(an_actor is Mob)
	mob = an_actor as Mob


func _castle() -> Castle:
	return get_tree().get_first_node_in_group("castle") as Castle
