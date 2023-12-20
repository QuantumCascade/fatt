class_name HpBar
extends ProgressBar



func _on_value_changed(new_hp: float):
	if new_hp >= max_value:
		hide()
	else:
		show()
	var perc: float = new_hp / max_value
	if perc < 0.3:
		modulate = Color.RED
	elif perc < 0.5:
		modulate = Color.YELLOW
	else:
		modulate = Color.GREEN
