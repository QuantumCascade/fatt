class_name CastleBody extends StaticBody2D

const kind = "CastleBody"

@export var hp: float = 150

@onready var castle: Castle = get_parent()

func _ready():
	$HpBar.max_value = hp
	$HpBar.value = hp
	$HpBar.visible = false

func receive_dmg(dmg: float, attacker: Node) -> void:
	hp = max(hp - dmg, 0)
	print(castle.getId() + " received " + str(dmg) \
		+ " dmg from [" + str(attacker) + "] >> hp=" + str(hp))
	$HpBar.value = hp
	$HpBar.visible = true
	if hp/$HpBar.max_value < 0.5:
		$HpBar.modulate = Color.RED


func get_pid():
	return castle.master.pid

func _to_string():
	return str(castle)
