class_name BuildTowerMenu extends PopupMenu

var selected_tower_id: int = -1
var confirmed: bool = false

var tower_ids: Array[int] = [0]
var confirm_id = 2

signal build_tower_selected
signal build_tower_confirmed
signal build_tower_closed

func _on_popup_hide():
	build_tower_closed.emit()

func _on_close_requested():
	build_tower_closed.emit()


func _on_id_pressed(id):
	if tower_ids.has(id):
		selected_tower_id = id
		set_item_disabled(confirm_id, false)
		build_tower_selected.emit(id)
	elif id == confirm_id:
		confirmed = true
		if selected_tower_id >= 0:
			build_tower_confirmed.emit(id)
