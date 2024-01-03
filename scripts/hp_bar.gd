class_name HpBar
extends ProgressBar


func init_val(base_hp: float):
	max_value = base_hp
	value = base_hp


func _on_value_changed(new_hp: float):
	if new_hp >= max_value || new_hp <= 0:
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
