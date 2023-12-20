class_name BuilderState
extends MobState

var builder: Builder

func setup(an_actor: Node):
	super.setup(an_actor)
	assert(an_actor is Builder)
	builder = an_actor as Builder

