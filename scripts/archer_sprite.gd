class_name ArcherSprite
extends MobSprite


@onready var anim_player: AnimationPlayer = %AnimationPlayer


func play(anim_name: String) -> void:
	anim_player.play(anim_name)
