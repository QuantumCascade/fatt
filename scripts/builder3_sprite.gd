class_name Builder3Sprite
extends MobSprite

@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = %AudioPlayer

signal hammer_animation_performed

func play(anim_name: String) -> void:
	anim_player.play(anim_name)


func _on_hammer_animation_performed():
	hammer_animation_performed.emit()
	audio_player.pitch_scale = randf_range(0.85, 1.25)
	audio_player.play()


func play_idle_2():
	anim_player.play("idle_2")
