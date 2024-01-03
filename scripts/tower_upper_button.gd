class_name TowerUpperButton
extends PanelContainer

## A button above tower. Generally used to hire a minion for the tower.


# Emits self
signal button_pressed


@onready var button_border: Panel = %ButtonBorder


var border_alerting_color_shift: Vector3


func _process(delta):
	if border_alerting_color_shift:
		button_border.modulate.r -= delta * border_alerting_color_shift.x
		button_border.modulate.g -= delta * border_alerting_color_shift.y
		button_border.modulate.b -= delta * border_alerting_color_shift.z
		if button_border.modulate.b < 0 or button_border.modulate.b > 1:
			border_alerting_color_shift *= -1



func _on_texture_button_pressed():
	print("pressed %s" % self)
	button_pressed.emit(self)

