extends Node
class_name State

var actor: Node

signal state_transition

func setup(an_actor: Node):
	self.actor = an_actor

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_process(_delta: float):
	pass

func _physics_process(delta: float):
	if not actor:
		return
	physics_process(delta)

