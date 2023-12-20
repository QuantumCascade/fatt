class_name GameStats


static var mob_stats: Array[MobStats] = [
	MobStats.from_mob_dict({
		"name": "builder",
		"cost": 0,
		"movement_speed": 100,
		"max_hp": 100,
		"armor": 0,
		"resource": preload("res://scenes/builder.tscn")
	})
]

static var tower_stats: Array[TowerStats] = [
		TowerStats.from_tower_dict({
			"id": 0,
			"name": "Archer Tower", 
			"description": "Archers shoot from a safe distance",
			"cost": 100,
			"img": preload("res://assets/sprites/buildings/tower-wooden-1.png"),
			"icon": preload("res://assets/sprites/icons/bow-icon-1.png"),
			"dmg": 50,
			"atk_spd": 2,
			"atk_range": 200,
			"arc_height": 75,
			"building_time": 3,
		}),
		
		TowerStats.from_tower_dict({
			"id": 1,
			"name": "Crossbow Tower", 
			"description": "Heavy crossbows bolts cause knockback",
			"cost": 120,
			"img": preload("res://assets/sprites/buildings/stone-tower-1.webp"),
			"icon": preload("res://assets/sprites/icons/bow-icon-1.png"),
			"dmg": 75,
			"atk_spd": 4,
			"knockback": 15,
			"atk_range": 175,
			"arc_height": 15,
			"building_time": 7,
		}),
		
		TowerStats.from_tower_dict({
			"id": 2,
			"name": "Defender Tower", 
			"description": "Defenders protected with strong armor and shields can stop anyone",
			"cost": 150,
			"img": preload("res://assets/sprites/buildings/fortified-tower-1.webp"),
			"icon": preload("res://assets/sprites/icons/sword-icon-1.png"),
			"dmg": 40,
			"atk_spd": 3,
			"knockback": 10,
			"building_time": 10,
		}),
	]
