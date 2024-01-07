class_name CreepAttacking
extends CreepState

var attacks_performed: int = 0

func enter():
	if not creep.is_attackable(creep.attack_target):
		print("%s cannot attack %s" % [creep, creep.attack_target])
		state_transition.emit(self, "Idle")
		return
	creep.sprite.attack_animation_complete.connect(_on_attack_animation_complete)
	attacks_performed = 0
	init_attack_action()
	creep.switch_attack(true)

func exit():
	creep.switch_attack(false)
	creep.sprite.attack_animation_complete.disconnect(_on_attack_animation_complete)


func init_attack_action():
	creep.play_anim("attack")
	creep.play_audio("attack")
	print("%s attacking [%s] >> %s" % [creep, 1 + attacks_performed, creep.attack_target])


func _on_attack_animation_complete():
	attacks_performed += 1
		
	if not creep.is_attackable(creep.attack_target):
		state_transition.emit(self, "Idle")
		return
	 
	creep.flip_to(creep.attack_target.global_position - creep.global_position)
	call_deferred("init_attack_action")


func _physics_process(_delta: float):
	
	if not mob:
		return
	
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
