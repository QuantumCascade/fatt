class_name ArcherAttacking
extends ArcherState


var attacks_performed: int = 0

func enter():
	if not archer.is_attackable(archer.enemy_to_attack):
		print("%s cannot attack %s" % [archer, archer.enemy_to_attack])
		state_transition.emit(self, "Idle")
		return
	archer.sprite.attack_animation_complete.connect(_on_attack_animation_complete)
	attacks_performed = 0
	init_attack_action()


func exit():
	archer.sprite.attack_animation_complete.disconnect(_on_attack_animation_complete)
	archer.play_anim("idle")


func init_attack_action():
	print("%s shooting" % archer)
	archer.sprite.anim_player.stop()
	archer.play_anim("attack")


func _on_attack_animation_complete():
	attacks_performed += 1
	
	if not archer.is_attackable(archer.enemy_to_attack):
		state_transition.emit(self, "Idle")
		return
	
	print("%s next arrow..." % archer)
	archer.flip_to(archer.enemy_to_attack.global_position - archer.global_position)
	call_deferred("init_attack_action")


func _physics_process(_delta: float):
	
	if not mob:
		return
	
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
