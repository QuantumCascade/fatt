class_name SnakeCreep
extends Creep



func _ready():
	
	# Init Mob common components
	state_machine = %StateMachine
	steering = %Steering
	nav_agent = %NavAgent
	audible = %Audible
	
	# Init Creep common components
	attack_area = %AttackArea
	vision_area = %VisionArea
	
	# Init Snake personal components 
	hp_bar = %HpBar
	hitbox = %Hitbox
	sprite = %Sprite
	(sprite as SnakeSprite).dmg_area.area_entered.connect(_on_dmg_area_area_entered)


func _to_string():
	return "creep @ %s" % global_position


func play_audio(sound: String):
	match sound:
		"hit_hurt":
			audible.stream = preload("res://assets/sounds/hit_hurt.wav")
			audible.play()
		"attack":
			audible.stream = preload("res://assets/sounds/swoosh.wav")
			audible.play()


func _on_dmg_area_area_entered(hitbox_area: Hitbox):
	var body = hitbox_area.get_parent()
	print("%s: bite %s" % [self, body])
	if body and body.has_method("take_dmg"):
		body.take_dmg(stats.dmg)
	else:
		print("err: %s target %s without `take_dmg`" % [self, hitbox_area])


