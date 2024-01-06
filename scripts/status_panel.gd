class_name StatusPanal
extends PanelContainer


@onready var hammer_icon: TextureRect = %HammerIcon
@onready var builders_label: Label = %BuildersLabel
@onready var people_icon: TextureRect = %PeopleIcon
@onready var population_label: Label = %PopulationLabel
@onready var building_materials_label: Label = %BuildingMaterialsLabel
@onready var gold_label: Label = %GoldLabel


func update_vals(vals: Dictionary):
	if "gold" in vals:
		gold_label.text = str(vals.get("gold"))
	if "gold_mining_speed" in vals:
		gold_label.text += " (+%s)" % [vals.get("gold_mining_speed")]
	if "building_materials" in vals:
		building_materials_label.text = "%s" % [vals.get("building_materials")]
	if "building_materials_mining_speed" in vals:
		building_materials_label.text += " (+%s)" % [vals.get("building_materials_mining_speed")]
	if "builders" in vals:
		builders_label.text = str(vals.get("builders"))
	if "population" in vals:
		population_label.text = str(vals.get("population"))

