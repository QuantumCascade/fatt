class_name TowerUpperButtons
extends PanelContainer


# List of buttons above a tower. Generally to hire minions for the tower.


@onready var h_box_container: HBoxContainer = %HBoxContainer

func _ready():
	remove_all_buttons()

func remove_all_buttons():
	h_box_container.get_children().all(func(btn): btn.queue_free())


func add_button(new_button: Node):
	h_box_container.add_child(new_button)


func get_buttons() -> Array[Node]:
	return h_box_container.get_children()
