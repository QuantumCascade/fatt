class_name ArcherDying
extends ArcherState


# Seconds to disappear the corpse
const decay_speed: float = 20 


func enter():
	mob.play_anim("die")
	archer.hitbox.monitorable = false # enemies don't need to worry about this target anymore
	mob.collision_layer = 0 # it is dead - anybody can step on the corpse
	mob.remove_from_group("player_minions")
	# TODO: drop valuables?


func _physics_process(delta: float):
	if not mob:
		return
	if archer.sprite.modulate.a > 0:
		archer.sprite.modulate.a -= max(0, delta / decay_speed)
	else:
		archer.finally_decayed()
