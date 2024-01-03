class_name MobStats

var name: String = "mob"
var hp: float = 100
var max_hp: float = 100
var movement_speed: float = 0

var dmg: float = 0
#var atk_spd: float = 0
#var atk_range: float = 0
#var vision_range: float = 100
var knockback: float = 0

var cost: float = 0

var resource: Resource


static func from_mob_dict(dict: Dictionary) -> MobStats:
	var new_stats: MobStats = MobStats.new()
	new_stats.init_from_dict(dict)
	return new_stats


func init_from_dict(dict: Dictionary):
	for prop in self.get_property_list():
		if dict.has(prop.name):
			self[prop.name] = dict.get(prop.name)
	if not dict.has("hp"):
		hp = max_hp


func clone() -> MobStats:
	var new_stats: MobStats = MobStats.new()
	for prop in self.get_property_list():
		new_stats.set(prop.name, self.get(prop.name))
	return new_stats
