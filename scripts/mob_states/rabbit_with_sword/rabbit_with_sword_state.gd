class_name RabbitWithSwordState
extends MobState

var rabbit: RabbitWithSword


func setup(an_actor: Node):
	super.setup(an_actor)
	assert(an_actor is RabbitWithSword)
	rabbit = an_actor as RabbitWithSword
