class_name RabbitWithSwordIdle
extends RabbitWithSwordState


var resting_time_on_idle: float = 0.5
# if resting then wait for a while before looking for new opportunities
var resting_time: float

var anim_timer: Timer


func enter() -> void:
	resting_time = resting_time_on_idle
	rabbit.play_anim("idle_2")
	setup_anim_timer()


func setup_anim_timer():
	if anim_timer:
		anim_timer.queue_free()
	anim_timer = disposable_timer(play_idle_anim, randf_range(3, 12))
	add_child(anim_timer)


func play_idle_anim():
	if not is_inside_tree():
		return # if detached from state machine then ignore timer signal
	rabbit.play_anim("idle")
	setup_anim_timer()


func exit():
	pass


func physics_process(delta: float):
	
	if not mob:
		return
	
	if mob.stats.hp <= 0:
		state_transition.emit(self, "Dying")
		return
	
	resting_time = max(resting_time - delta, 0)
	
	if resting_time > 0:
		return

	if rabbit.check_enemies_in_attack_area():
		print("%s sudden enemy in attack area: %s" % [rabbit, rabbit.enemy_to_attack])
		state_transition.emit(self, "Attacking")
	
	var visible_enemy = rabbit.check_visible_enemies()
	if visible_enemy:
		rabbit.enemy_to_attack = visible_enemy
		print("%s spotted enemy - approaching %s" % [rabbit, rabbit.enemy_to_attack])
		rabbit.movement_target = rabbit.enemy_to_attack.global_position
		state_transition.emit(self, "Moving")
		return

	if rabbit.movement_target != Vector2.ZERO:
		print("%s got new order - move to %s" % [rabbit, rabbit.movement_target])
		state_transition.emit(self, "Moving")
		return

