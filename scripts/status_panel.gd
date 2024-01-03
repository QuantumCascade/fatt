class_name StatusPanal
extends PanelContainer


@onready var hammer_icon: TextureRect = %HammerIcon
@onready var builders_label: Label = %BuildersLabel
@onready var people_icon: TextureRect = %PeopleIcon
@onready var population_label: Label = %PopulationLabel


func update_vals(vals: Dictionary):
	if "builders" in vals:
		builders_label.text = str(vals.get("builders"))
	if "population" in vals:
		population_label.text = str(vals.get("population"))

