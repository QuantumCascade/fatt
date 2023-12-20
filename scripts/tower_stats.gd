extends BuildingStats
class_name TowerStats

var icon: Resource
var dmg: float = 0.0
var atk_spd: float = 0.0
var atk_range: float = 0.0
var knockback: float = 0.0
var arc_height: float = 0.0


func init_from_dict(dict: Dictionary):
	for prop in get_property_list():
		if dict.get(prop.name):
			self[prop.name] = dict.get(prop.name, self.get(prop.name))


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
