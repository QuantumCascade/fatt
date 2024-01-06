class_name PlayerStats
extends Node


var building_materials: float = 200
var building_materials_mining_speed: float = 0.7
var gold: float = 30
var gold_mining_speed: float = 0.3
var population: float = 5
var init_minions: Dictionary = {
	"builder": 1
}

func init_from_dict(dict: Dictionary):
	for prop in get_property_list():
		if dict.get(prop.name):
			self[prop.name] = dict.get(prop.name, self.get(prop.name))

