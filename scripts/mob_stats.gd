class_name MobStats

var name: String = "mob"
var hp: float = 100
var max_hp: float = 100
var movement_speed: float = 200

var dmg: float = 0
var atk_spd: float = 0
var atk_range: float = 0
var knockback: float = 0

var cost: float = 10

var resource: Resource


static func from_mob_dict(dict: Dictionary) -> MobStats:
	var stats: MobStats = MobStats.new()
	stats.init_from_dict(dict)
	return stats


func init_from_dict(dict: Dictionary):
	for prop in get_property_list():
		if dict.has(prop.name):
			self[prop.name] = dict.get(prop.name, self.get(prop.name))
	hp = max_hp


func clone() -> MobStats:
	var stats: MobStats = MobStats.new()
	for prop in get_property_list():
		if self.get(prop.name):
			stats[prop.name] = self.get(prop.name)
	return stats
