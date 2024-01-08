class_name RabbitWithSword
extends Minion


@onready var attack_area: AttackArea = %AttackArea


var enemy_to_attack: Node2D


func _ready():
	
	# Init Mob common components
	state_machine = %RabbitWithSwordStateMachine
	steering = %Steering
	nav_agent = %NavAgent
	audible = %Audible
	
	# Init Minion personal components 
	hp_bar = %HpBar
	hitbox = %Hitbox
	sprite = %Sprite
	vision_area = %VisionArea
	(sprite as RabbitWithSwordSprite).dmg_area.area_entered.connect(_on_dmg_area_area_entered)


func _on_dmg_area_area_entered(hitbox_area: Hitbox):
	var body = hitbox_area.get_parent()
	print("%s: hit %s" % [self, body])
	if body and body.has_method("take_dmg"):
		body.take_dmg(stats.dmg)
	else:
		print("err: %s target %s without `take_dmg`" % [self, hitbox_area])




func check_enemies_in_attack_area() -> bool:
	if attack_area.get_overlapping_areas().is_empty():
		return false
	var enemy_hitbox: Hitbox = attack_area.get_overlapping_areas()[0] as Hitbox
	enemy_to_attack = enemy_hitbox.get_parent()
	if not enemy_to_attack:
		return false
	return true


# Returns true if body is in attack area and has hitbox
func is_attackable(body: Node) -> bool:
	return body and attack_area.get_overlapping_areas().has(body.hitbox)

