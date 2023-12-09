extends Node

@onready var p = $Projectile
var dir = 1

var tm = 2
var b: bool = true

func _ready():
	p.rotation_degrees = 45

func _physics_process(_delta):
	p.is_stuck = true
	
	$CharacterBody2D.velocity = Vector2.LEFT * 50
	$CharacterBody2D.move_and_slide()


func _on_timer_timeout():
	print("reparent to %s" % p.position)
	
	p.position = Vector2.ZERO # $CharacterBody2D.position
	#p.position.y += 1
	p.reparent($CharacterBody2D)


	#if b:
		#p.position = Vector2.ZERO # $CharacterBody2D.position
		#p.position.y -= 10
		#p.reparent($CharacterBody2D)
		#print("char pos %s" % $CharacterBody2D.position)
		#b = !b
	#else:
		#p.position = Vector2.ZERO # $CharacterBody2D.position
		#p.position.y -= 10
		#p.reparent($CharacterBody2D2)
		#print("char pos %s" % $CharacterBody2D2.position)
		#b = !b
