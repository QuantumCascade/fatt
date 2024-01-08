extends Node2D

@onready var nav_region: NavigationRegion2D = $NavigationRegion2D


var under_control: Mob


func _ready():
	($Builder as Builder).setup(GameStats.get_mob_stats("builder"))
	($Builder as Builder).input_emitter.connect(func(_event): set_under_control(($Builder as Builder)))

	($RabbitWithSword as RabbitWithSword).setup(GameStats.get_mob_stats("rabbit_with_sword"))
	($RabbitWithSword as RabbitWithSword).input_emitter.connect(func(_event): set_under_control(($RabbitWithSword as RabbitWithSword)))

	
	($SnakeCreep as Creep).setup(GameStats.get_mob_stats("snake"))
	($SnakeCreep as Creep).input_emitter.connect(func(_event): set_under_control(($SnakeCreep as Creep)))
	
	under_control = ($SnakeCreep as Creep)

	for child in get_children():
		if child is Archer:
			(child as Archer).setup(GameStats.get_mob_stats("archer"))
			child.add_to_group("player_minions")
			(child as Archer).input_emitter.connect(func(_event): set_under_control(child))

	for child in get_children():
		if child is Tower:
			(child as Tower).setup(GameStats.get_tower_stats(1))

func set_under_control(mob: Mob):
	print("set under control: %s" % mob)
	under_control = mob



func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("click"):
		print("caught click %s: %s" % [get_global_mouse_position(), event])
		if under_control:
			under_control.movement_target = get_global_mouse_position()


func _on_button_pressed():
	print("gui button pressed %s" % get_global_mouse_position())
