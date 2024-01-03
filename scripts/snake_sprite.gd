class_name SnakeSprite
extends MobSprite

@onready var animation_player: AnimationPlayer = %AnimationPlayer

#func _physics_process(delta):
	#dissolve(delta)
	

func play(anim_name: String) -> void:
	animation_player.stop()
	animation_player.play(anim_name)
