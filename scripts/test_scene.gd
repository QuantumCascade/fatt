extends Node2D

@onready var mob: Mob = $Archer
@onready var nav_region: NavigationRegion2D = $NavigationRegion2D


func _ready():
	($Builder as Builder).setup(GameStats.get_mob_stats("builder"))
	($Builder as Builder).add_to_group("player_minions")
	($SnakeCreep as Creep).setup(GameStats.get_mob_stats("snake"))
	for child in get_children():
		if child is Archer:
			(child as Archer).setup(GameStats.get_mob_stats("archer"))
			child.add_to_group("player_minions")
	for child in get_children():
		if child is Tower:
			(child as Tower).setup(GameStats.get_tower_stats(1))

func _unhandled_input(event):
	if event.is_action_pressed("click"):
		print("caught click %s" % get_global_mouse_position())
		($SnakeCreep as Creep).movement_target = get_global_mouse_position()


func _on_button_pressed():
	print("gui button pressed %s" % get_global_mouse_position())
