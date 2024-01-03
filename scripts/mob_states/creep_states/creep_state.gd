class_name CreepState
extends MobState

var creep: Creep

func setup(an_actor: Node):
	super.setup(an_actor)
	assert(an_actor is Creep)
	creep = an_actor as Creep

