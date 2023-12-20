extends Panel

var highlighted_theme = preload("res://themes/panel_hover.tres")
var id

signal clicked

func _on_mouse_entered():
	theme = highlighted_theme

func _on_mouse_exited():
	theme = null

func _input(event):
	if event.is_action_pressed("click") && theme == highlighted_theme:
		clicked.emit(id)
