class_name BuilderDying
extends BuilderState

# Seconds to disappear the corpse
const decay_speed: float = 10 


func enter() -> void:
	builder.anim_player.play("die")
	builder.hp_bar.hide()
	builder.hitbox.monitorable = false # enemies don't need to worry about this target anymore
	builder.collision_layer = 0 # it is dead - anybody can step on the corpse
	builder.remove_from_group("player_mobs")
	# TODO: drop valuables?


func _physics_process(delta: float):
	if builder.sprite.modulate.a > 0:
		builder.sprite.modulate.a -= max(0, delta / decay_speed)
	else:
		# TODO: cleanup?
		queue_free()
