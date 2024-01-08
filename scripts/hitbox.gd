class_name Hitbox
extends Area2D

signal input_emitter

var hover: bool = false


func _input(event: InputEvent):
	if hover:
		input_emitter.emit(event)
		get_viewport().set_input_as_handled()


func _mouse_enter():
	hover = true
	
	
func _mouse_exit():
	hover = false
