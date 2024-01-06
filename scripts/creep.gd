class_name Creep
extends Mob

## Abstract base class for creeps

# Each ancestor should set this components during setup/init
var hp_bar: HpBar
var hitbox: Hitbox
var sprite: MobSprite
var attack_area: AttackArea
var vision_area: VisionArea

var visible_target: Node2D
var attack_target: Node2D


func setup(new_stats: MobStats):
	super.setup(new_stats)
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.hp
	#attack_area.radius = stats.atk_range
	#vision_area.radius = stats.vision_range
	state_machine.setup(self)
	#sprite.attack_animation_performed.connect(_on_attack_animation_performed)
	sprite.death_animation_performed.connect(_on_death_animation_performed)


func play_anim(anim_name: String):
	sprite.play(anim_name)


func flip_to(target: Vector2):
	sprite.flip_to(target)


func take_dmg(dmg: float):
	super.take_dmg(dmg)
	hp_bar.value = stats.hp


func switch_attack(is_attacking: bool):
	if "dmg_area" in sprite:
		var dmg_area: Area2D = sprite.dmg_area as Area2D
		dmg_area.monitoring = is_attacking


#func _on_attack_animation_performed():
	#print("%s atk with dmg=%s: %s" % [self, stats.dmg, attack_target])
	#if is_attackable(attack_target):
		#attack_target.take_dmg(stats.dmg)
		

# Returns true if body is in attack area and has hitbox
func is_attackable(body: Node) -> bool:
	return body and attack_area.get_overlapping_areas().has(body.hitbox)


func _on_death_animation_performed():
	print("%s dead" % self)
	death_animation_performed.emit(self)


# Check if see any target - if yes then set self.visible_target
func check_visible_targets():
	var visible_targets: Array[Area2D] = vision_area.get_overlapping_areas()
	if visible_target and visible_targets.has(visible_target.hitbox):
		# stick to the prev target ?
		return
	visible_targets.sort_custom(choose_closest)
	for visible_hitbox in visible_targets:
		var body = visible_hitbox.get_parent()
		visible_target = body
		return
	# If see nobody - then forget prev target
	visible_target = null


# Check if close enough to perform an attack - if yes then set self.attack_target
func check_attackable_targets():
	var attackable_targets: Array[Area2D] = attack_area.get_overlapping_areas()
	if attack_target and attackable_targets.has(attack_target.hitbox):
		# stick to the prev target
		return
	attackable_targets.sort_custom(choose_closest)
	for attackable_hitbox in attackable_targets:
		var body = attackable_hitbox.get_parent()
		attack_target = body
		return
	# If nobody close enough - then forget prev target
	attack_target = null

func _to_string():
	return "creep @ %s" % global_position
