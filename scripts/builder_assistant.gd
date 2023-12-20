## Manages Tower Placeholder
class_name BuilderAssistant
extends Node2D


signal tower_pos_chosen


var tower_placeholder: TowerPlaceholder


func _ready():
	tower_placeholder = preload("res://scenes/tower_placeholder.tscn").instantiate()
	tower_placeholder.hide()
	add_child(tower_placeholder)


func _input(event: InputEvent):
	if event.is_action_pressed("click"):
		if not tower_placeholder.visible:
			return
		tower_placeholder.hide()
		tower_pos_chosen.emit(tower_placeholder.global_position)


func _on_pointed_tower_lane_pos(pos: Vector2):
	if pos != Vector2.ZERO:
		tower_placeholder.global_position = pos
		if !tower_placeholder.building_area.get_overlapping_areas().is_empty():
			pos = Vector2.ZERO
	if pos != Vector2.ZERO:
		_show_tower_placeholder(pos)
	else:
		tower_placeholder.hide()


func _show_tower_placeholder(pos: Vector2):
	tower_placeholder.global_position = pos
	tower_placeholder.show()

