class_name RabbitWithSwordAttacking
extends RabbitWithSwordState


var attacks_performed: int = 0

func enter():
	if not rabbit.is_attackable(rabbit.enemy_to_attack):
		print("%s cannot attack %s" % [rabbit, rabbit.enemy_to_attack])
		state_transition.emit(self, "Idle")
		return
	rabbit.sprite.attack_animation_complete.connect(_on_attack_animation_complete)
	attacks_performed = 0
	init_attack_action()


func exit():
	rabbit.sprite.attack_animation_complete.disconnect(_on_attack_animation_complete)
	rabbit.play_anim("idle")


func init_attack_action():
	print("%s swinging sword" % rabbit)
	rabbit.sprite.anim_player.stop()
	rabbit.play_anim("attack")


func _on_attack_animation_complete():
	attacks_performed += 1
	
	if not rabbit.is_attackable(rabbit.enemy_to_attack):
		state_transition.emit(self, "Idle")
		return
	
	print("%s next swing..." % rabbit)
	rabbit.flip_to(rabbit.enemy_to_attack.global_position - rabbit.global_position)
	call_deferred("init_attack_action")


func _physics_process(_delta: float):
	
	if not mob:
		return
	
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return

