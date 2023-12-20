class_name MobState
extends State

var mob: Mob

func setup(an_actor: Node):
	super.setup(an_actor)
	assert(an_actor is Mob)
	mob = an_actor as Mob

