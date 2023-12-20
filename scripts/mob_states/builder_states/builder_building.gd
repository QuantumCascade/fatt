class_name BuilderBuilding
extends BuilderState


func enter() -> void:
	builder.anim_player.play("idle")

func exit():
	pass

func physics_process(delta: float):
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
	if not builder.building_target:
		state_transition.emit(self, "Idle")
		return
	if builder.building_target.stats.building_time <= 0:
		state_transition.emit(self, "Idle")
		return
	if builder.movement_target != Vector2.ZERO:
		state_transition.emit(self, "Idle")
		return
	if builder.in_building_area():
		builder.building_target.process_building(delta)
