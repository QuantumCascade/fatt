extends BuildingStats
class_name TowerStats

var icon: Resource
var dmg: float = 0.0
var atk_spd: float = 0.1
var between_atk_cooldown: float = 1
var atk_range: float = 0.0
var knockback: float = 0.0
var arc_height: float = 0.0
var projectile_speed: float = 1.0
var max_minions_in_tower: int = 0
var wanted_minion_in_tower: String = ""

func init_from_dict(dict: Dictionary):
	for prop in self.get_property_list():
		if dict.has(prop.name):
			self[prop.name] = dict.get(prop.name)
	#for prop in dict:
		#if self.get_property_list().has(prop):
			#self[prop] = dict.get(prop)


static func from_tower_dict(dict: Dictionary) -> TowerStats:
	var stats: TowerStats = TowerStats.new()
	stats.init_from_dict(dict)
	return stats


func clone() -> TowerStats:
	var stats: TowerStats = TowerStats.new()
	for prop in get_property_list():
		if self.get(prop.name):
			stats[prop.name] = self.get(prop.name)
	return stats
