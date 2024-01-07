class_name BuilderBuilding
extends BuilderState

var audio_player: AudioStreamPlayer2D
var building_finished: bool

func enter() -> void:
	building_finished = false
	if (builder.sprite as Builder3Sprite).hammer_animation_performed.is_connected(switch_to_idle):
		(builder.sprite as Builder3Sprite).hammer_animation_performed.disconnect(switch_to_idle)
	builder.play_anim("hammer")

func exit():
	if (builder.sprite as Builder3Sprite).hammer_animation_performed.is_connected(switch_to_idle):
		(builder.sprite as Builder3Sprite).hammer_animation_performed.disconnect(switch_to_idle)
	pass

func switch_to_idle():
	state_transition.emit(self, "Idle")
	pass

func physics_process(delta: float):
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
	if not builder.building_target:
		state_transition.emit(self, "Idle")
		return
	if builder.building_target.stats.building_time <= 0:
		if not building_finished:
			building_finished = true
			(builder.sprite as Builder3Sprite).hammer_animation_performed.connect(switch_to_idle)
		return
	if builder.movement_target != Vector2.ZERO:
		state_transition.emit(self, "Idle")
		return
	if builder.in_building_area():
		builder.building_target.process_building(delta)
	else:
		print("%s suddely out of construction zone")
		state_transition.emit(self, "Idle")
		
