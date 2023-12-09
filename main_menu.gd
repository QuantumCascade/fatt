class_name MainMenu extends Control


func _on_start_pressed():
	get_tree().change_scene_to_packed(preload("res://main_scene.tscn"))

func _on_exit_pressed():
	get_tree().quit()
