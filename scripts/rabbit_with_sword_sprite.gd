class_name RabbitWithSwordSprite
extends MobSprite

@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var dmg_area: Area2D = %DmgArea



func play(anim_name: String) -> void:
	anim_player.play(anim_name)


func play_idle_2():
	anim_player.play("idle_2")
