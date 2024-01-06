class_name ArcherBSprite
extends MobSprite


@onready var anim_player: AnimationPlayer = %AnimationPlayer


func play(anim_name: String) -> void:
	anim_player.play(anim_name)


func play_idle_2():
	anim_player.play("idle_2")
