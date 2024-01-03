class_name Minion
extends Mob

## Abstact class for mobs under player control

# Each ancestor should set this components during setup/init
var hp_bar: HpBar
var hitbox: Hitbox
var sprite: MobSprite
var vision_area: VisionArea


func setup(new_stats: MobStats):
	super.setup(new_stats)
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.hp
	state_machine.setup(self)
	sprite.death_animation_performed.connect(_on_death_animation_performed)


func play_anim(anim_name: String):
	sprite.play(anim_name)


func flip_to(target: Vector2):
	if target.x < 0:
		if not sprite.is_flipped_h():
			sprite.flip_h = true
	else:
		if sprite.is_flipped_h():
			sprite.flip_h = false

func hiding_in_castle():
	movement_target = Vector2()
	state_machine.set_state("Idle")

func _on_death_animation_performed():
	print("%s dead" % self)
	death_animation_performed.emit(self)



func _spawn_area() -> PlayerSpawnArea:
	return get_tree().get_first_node_in_group("player_spawn_area") as PlayerSpawnArea
