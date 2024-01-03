class_name Castle
extends StaticBody2D


@export var hp: float = 1000


@onready var hp_bar: HpBar = %HpBar
@onready var hitbox: Hitbox = %Hitbox


func _ready():
	hp_bar.max_value = hp
	hp_bar.value = hp


func _physics_process(_delta: float):
	
	if hp <= 0:
		hitbox.monitorable = false
		print("castle destroyed")


func take_dmg(dmg: float):
	print("took_dmg: %s" % dmg)
	hp = max(hp - dmg, 0)
	hp_bar.value = hp

