class_name Castle extends Node2D

const kind = "Castle"

enum State { WAITING, DESTROYED }

@export var vision_range: float = 300
@export var attack_range: float = 10
@export var state: State = State.WAITING
@export var master: Player

@onready var spawnArea: Area2D = $SpawnArea
@onready var body: CastleBody = $CastleBody

func _ready():
	print(getId() + " spawned at " + str(position))

func _physics_process(_delta: float):
	if body.hp <= 0 && state != State.DESTROYED:
		state = State.DESTROYED
		$DestroyedSfx.pitch_scale = randf_range(0.8, 1.2)
		$DestroyedSfx.play()
		print(getId() + " destroyed!")

func apply_color_mod(color_mod: Color):
	$Sprite2D.modulate = $Sprite2D.modulate + color_mod

func getId() -> String:
	return "castle@" + master.pid

func _to_string():
	return getId() + "|" + str(body.hp) + "hp"

