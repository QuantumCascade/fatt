class_name PlayerStats
extends Node


var building_materials: float = 1000
var spawn_materials: float = 1000
var population: float = 2



func init_from_dict(dict: Dictionary):
	for prop in get_property_list():
		if dict.get(prop.name):
			self[prop.name] = dict.get(prop.name, self.get(prop.name))

