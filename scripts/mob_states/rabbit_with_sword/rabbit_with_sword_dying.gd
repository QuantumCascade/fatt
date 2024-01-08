class_name RabbitWithSwordDying
extends RabbitWithSwordState

# Seconds to disappear the corpse
const decay_speed: float = 20 


func enter():
	mob.play_anim("die")
	rabbit.hitbox.monitorable = false # enemies don't need to worry about this target anymore
	mob.collision_layer = 0 # it is dead - anybody can step on the corpse
	mob.remove_from_group("player_minions")
	# TODO: drop valuables?


func _physics_process(delta: float):
	if not rabbit:
		return
	
	if rabbit.sprite.dissolve(delta / decay_speed) == 0:
		rabbit.finally_decayed()

