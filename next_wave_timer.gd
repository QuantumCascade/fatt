class_name NextWaveTimer extends Label

var time_to_attack: float = -1

@onready var main_scene: MainScene = get_parent()

func _process(delta):
	
	if main_scene.players["a"].castle.state == Castle.State.DESTROYED:
		text = "You lost this battle"
		return
	elif main_scene.players["b"].castle.state == Castle.State.DESTROYED:
		text = "Congratulations - you won this battle!"
		return
	
	var new_text: String = ""
	
	var stats: PlayerStats = main_scene.players["a"].stats
	new_text += stats.txt_spawn_readiness() + "\n"
	new_text += stats.txt_spawn_reserve_report(main_scene.players["a"]) + "\n"
	new_text += stats.txt_spawn_pool_remainings() + "\n"
	new_text += stats.txt_building_resource_report() + "\n"
	
	if time_to_attack > 0:
		time_to_attack = max(time_to_attack - delta, 0)
		new_text += "Next attack in: %d seconds" % time_to_attack
	elif time_to_attack != -1:
		time_to_attack = -1
		var remainings = floor(stats.spawn_resource_pool / stats.spawn_cost)
		var mobs = main_scene.players["a"].mobs.size()
		if mobs > 0 || remainings > 0:
			new_text += "\nAttack!"
		main_scene.swithch_to_war()
	text = new_text
	
