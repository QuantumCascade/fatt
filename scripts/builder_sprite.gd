class_name BuilderSprite
extends MobSprite

@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = %AudioPlayer

signal hammer_animation_performed

func play(anim_name: String) -> void:
	anim_player.play(anim_name)


func _on_hammer_animation_performed():
	hammer_animation_performed.emit()
	audio_player.play()
