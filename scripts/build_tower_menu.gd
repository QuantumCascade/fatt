class_name BuildTowerMenu 
extends Popup

var selected_tower_id: int = -1

var menu_options: Array[TowerStats] = []
var confirm_id = 2
var tower_placeholder: TowerPlaceholder

signal build_tower_selected
signal build_tower_confirmed
signal build_tower_closed


@onready var box_container: BoxContainer = %BoxContainer


func _ready():
	var list: Array[TowerStats] = []
	for dict in GameStats.tower_stats_list:
		list.append(TowerStats.from_tower_dict(dict))
	setup(list)


func setup(stats: Array[TowerStats]):
	menu_options.clear()
	for child in box_container.get_children():
		box_container.remove_child(child)
	for tower_stats in stats:
		var tower_panel: TowerPanel = preload("res://scenes/tower_panel.tscn").instantiate()
		tower_panel.clicked.connect(_on_id_pressed)
		box_container.add_child(tower_panel)
		tower_panel.setup(tower_stats)
		menu_options.append(tower_stats)
	size.x = 300 * menu_options.size()
	size.y = 250


func popup_at(pos: Vector2):
	if visible:
		return
	tower_placeholder = preload("res://scenes/tower_placeholder.tscn").instantiate()
	tower_placeholder.global_position = pos
	get_parent().add_child(tower_placeholder)
	popup()
	call_deferred("zoom_at_placeholder")


func zoom_at_placeholder():
	if not tower_placeholder:
		unzoom()
		return
	var delta: float = 50
	var cam: Cam = get_tree().get_first_node_in_group("cam") as Cam
	cam.smoothly_zoom(Vector2(2, 2))
	#cam.position = tower_placeholder.global_position + Vector2(0, delta*2)


func unzoom():
	var cam: Cam = get_tree().get_first_node_in_group("cam") as Cam
	cam.unzoom()


func _on_popup_hide():
	build_tower_closed.emit()
	if tower_placeholder:
		tower_placeholder.queue_free()
	unzoom()


func _on_id_pressed(id: int):
	print("pressed on %s" % id)
	if selected_tower_id == id:
		print("confirmed tower %s" % id)
		if tower_placeholder:
			build_tower_confirmed.emit(selected_tower_id, tower_placeholder.global_position)
		self.hide()
	selected_tower_id = id
	build_tower_selected.emit(id)

