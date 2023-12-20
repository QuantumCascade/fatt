extends Node
class_name StateMachine

@export var initial_state: State

var states = {}
var current_state: State
var actor: Node

func setup(an_actor: Node):
	self.actor = an_actor
	for state in get_children():
		if state is State:
			states[state.name] = state
			remove_child(state)
			state.setup(actor)
			state.state_transition.connect(on_state_transition)
	if initial_state:
		set_state(initial_state.name)

func on_state_transition(from: State, to: String) -> void:
	if current_state and from != current_state:
		return
	set_state(to)

func set_state(new_state: String):
	var cur_state_name = "null"
	if current_state:
		cur_state_name = current_state.name
		current_state.exit()
		remove_child(current_state)
	print("%s: %s -> %s" % [actor, cur_state_name, new_state])
	current_state = states[new_state]
	add_child(current_state)
	current_state.enter()
