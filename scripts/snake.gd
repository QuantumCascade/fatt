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

