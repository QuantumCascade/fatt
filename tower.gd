class_name Tower extends StaticBody2D

const kind = "Tower"

var master: Player

var enemies_in_range: Array[Unit] = []

var projectile_prefab = preload("res://projectiles/projectile.tscn")

var attack_cooldown: float = 0
var attack_cooldown_delta: float = 0.02

func _physics_process(_delta):
	
	if attack_cooldown > 0:
		attack_cooldown -= min(attack_cooldown, attack_cooldown_delta)
		if attack_cooldown == 0:
			print(getId() + " Recharged!")
	
	if !enemies_in_range.is_empty() && attack_cooldown <= 0:
		var projectile: Projectile = projectile_prefab.instantiate()
		projectile.global_position = global_position
		projectile.global_position.y = projectile.global_position.y - 100
		projectile.target = enemies_in_range[0]
		print(getId() + " attack >> " + str(projectile.target))
		get_parent().add_child(projectile)
		projectile.launch(self)
		attack_cooldown = 2


func _on_area_2d_body_entered(target):
	if Util.is_attackable_enemy(self, target):
		print(getId() + " i see >> " + str(target))
		enemies_in_range.append(target)


func _on_area_2d_body_exited(body):
	enemies_in_range.erase(body)

func getId() -> String:
	return "tower@" + master.pid

func get_pid():
	return master.pid
