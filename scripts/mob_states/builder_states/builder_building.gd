class_name BuilderBuilding
extends BuilderState

var audio_player: AudioStreamPlayer2D

func enter() -> void:
	builder.play_anim("hammer")
	if not audio_player:
		audio_player = AudioStreamPlayer2D.new()
		add_child(audio_player)
	audio_player.stream = preload("res://assets/sounds/hammering-on-wood_1-2-106583.mp3")
	audio_player.play()

func exit():
	audio_player.stop()
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
