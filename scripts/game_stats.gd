class_name GameStats


static func get_mob_stats(name: String) -> MobStats:
	for a_mob_stats in mob_stats_list:
		if a_mob_stats.name == name:
			return MobStats.from_mob_dict(a_mob_stats)
	return null


static func get_tower_stats(id: int) -> TowerStats:
	for a_tower_stats in tower_stats_list:
		if a_tower_stats.id == id:
			return TowerStats.from_tower_dict(a_tower_stats)
	return null


static var builder_stats: Dictionary = {
	"name": "builder",
	"cost": 0,
	"movement_speed": 50,
	"max_hp": 50,
	"armor": 0,
	"resource": load("res://scenes/builder.tscn"),
}


static var archer_stats: Dictionary = {
	"name": "archer",
	"cost": 10,
	"movement_speed": 55,
	"max_hp": 70,
	"armor": 3,
	"dmg": 35,
	"resource": load("res://scenes/archer.tscn"),
}


static var rabbit_with_sword_stats: Dictionary = {
	"name": "rabbit_with_sword",
	"cost": 100,
	"movement_speed": 60,
	"max_hp": 90,
	"armor": 10,
	"dmg": 135,
	"resource": load("res://scenes/rabbit_with_sword.tscn"),
}

static var snake_stats: Dictionary = {
	"name": "snake",
	"movement_speed": 75,
	"max_hp": 145,
	"armor": 0,
	"dmg": 20,
	#"atk_spd": 1.0/(1.7/3.0),
	"resource": load("res://scenes/snake.tscn"),
}


static var rat_stats: Dictionary = {
	"name": "rat",
	"movement_speed": 100,
	"max_hp": 30,
	"armor": 2,
	"dmg": 7,
	#"atk_spd": 1.0/(1.7/3.0),
	"resource": load("res://scenes/creep.tscn"),
}

static var mob_stats_list: Array[Dictionary] = [
	builder_stats,
	archer_stats,
	rabbit_with_sword_stats,
	snake_stats,
]

static var tower_stats_list: Array[Dictionary] = [
	{
		"id": 1,
		"name": "Archer Tower", 
		"description": "Archers shoot from a safe distance",
		"cost": 100,
		"img": load("res://assets/sprites/buildings/tower-wooden-1.png"),
		"icon": load("res://assets/sprites/icons/bow-icon-1.png"),
		"dmg": 40,
		"atk_spd": 0.5,
		"between_atk_cooldown": 0.3,
		"atk_range": 200,
		"arc_height": 75,
		"building_time": 3,
		"max_minions_in_tower": 2,
		"wanted_minion_in_tower": "archer",
	},
	
	{
		"id": 2,
		"name": "Crossbow Tower", 
		"description": "Heavy crossbows bolts cause knockback",
		"cost": 120,
		"img": load("res://assets/sprites/buildings/stone-tower-1.webp"),
		"icon": load("res://assets/sprites/icons/bow-icon-1.png"),
		"dmg": 1,
		"atk_spd": 0.4,
		"between_atk_cooldown": 0.3,
		"knockback": 15,
		"atk_range": 175,
		"arc_height": 5,
		"building_time": 10,
		"max_minions_in_tower": 2,
		"wanted_minion_in_tower": "crossbowman",
	},
	
	{
		"id": 3,
		"name": "Defender Tower", 
		"description": "Defenders protected with strong armor and shields can stop anyone",
		"cost": 150,
		"img": load("res://assets/sprites/buildings/fortified-tower-1.webp"),
		"icon": load("res://assets/sprites/icons/sword-icon-1.png"),
		"dmg": 40,
		"atk_spd": 1,
		"knockback": 10,
		"building_time": 15,
		"max_minions_in_tower": 2,
		"wanted_minion_in_tower": "defender",
	},
]
