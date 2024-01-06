class_name BuilderDying
extends BuilderState

# Seconds to disappear the corpse
const decay_speed: float = 20 


func enter() -> void:
	builder.play_anim("die")
	builder.hitbox.monitorable = false # enemies don't need to worry about this target anymore
	builder.collision_layer = 0 # it is dead - anybody can step on the corpse
	builder.remove_from_group("player_minions")
	# TODO: drop valuables?


func _physics_process(delta: float):
	if not builder:
		return
	
	if builder.sprite.dissolve(delta / decay_speed) == 0:
		builder.finally_decayed()
		
	#if builder.sprite.modulate.a > 0:
		#builder.sprite.modulate.a -= max(0, delta / decay_speed)
	#else:
		#builder.finally_decayed()

