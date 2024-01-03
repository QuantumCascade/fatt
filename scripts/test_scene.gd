extends Node2D

@onready var mob: Mob = $Archer
@onready var nav_region: NavigationRegion2D = $NavigationRegion2D


func _ready():
	($Tower as Tower).setup(GameStats.get_tower_stats(1))
	($Builder as Builder).setup(GameStats.get_mob_stats("builder"))
	($Archer as Archer).setup(GameStats.get_mob_stats("archer"))
	($SnakeCreep as Creep).setup(GameStats.get_mob_stats("snake"))


func _unhandled_input(event):
	if event.is_action_pressed("click"):
		print("caught click %s" % get_global_mouse_position())
		mob.movement_target = get_global_mouse_position()


func _on_button_pressed():
	print("gui button pressed %s" % get_global_mouse_position())
