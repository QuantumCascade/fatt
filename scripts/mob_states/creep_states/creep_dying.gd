class_name CreepDying
extends CreepState


# Seconds to disappear the corpse
const decay_speed: float = 20 


func enter():
	creep.play_anim("die")
	creep.hitbox.monitorable = false # enemies don't need to worry about this target anymore
	creep.collision_layer = 0 # it is dead - anybody can step on the corpse
	creep.remove_from_group("enemy_mobs")
	# TODO: drop valuables?


func _physics_process(delta: float):
	
	if not creep:
		return
	
	if creep.sprite.dissolve(delta / decay_speed) == 0:
		creep.finally_decayed()
		
	#if creep.sprite.modulate.a > 0:
		#creep.sprite.modulate.a -= max(0, delta / decay_speed)
	#else:
		#creep.finally_decayed()
