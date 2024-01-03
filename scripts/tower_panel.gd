class_name TowerPanel
extends Panel

## Container with available towers to build

signal clicked

var id
var stats: TowerStats

var highlighted_theme = preload("res://themes/panel_hover.tres")
var blocked_theme = preload("res://themes/panel_blocked.tres")

var dmg_icon = preload("res://assets/sprites/icons/dmg-icon-1.png")
var dist_icon = preload("res://assets/sprites/icons/dist-icon-1.png")
var range_icon = preload("res://assets/sprites/icons/aim-icon-1.png")
var clock_icon = preload("res://assets/sprites/icons/clock-icon-1.png")
var wood_icon = preload("res://assets/sprites/icons/wood-icon-1.png")

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: RichTextLabel = %Label


func _ready():
	if not get_parent():
		# just debug current scene
		setup(TowerStats.from_tower_dict(GameStats.tower_stats_list[0]))

func setup(a_stats: TowerStats):
	self.stats = a_stats
	self.id = stats.id
	print("%s with id=%s" % [stats.name, stats.id])

	texture_rect.texture = stats.img
	
	var txt = "%s [img=15x15]%s[/img]" % [stats.name, stats.icon.resource_path]
	
	if stats.get("dmg"):
		txt += "\n[color=green]dmg: %s[/color] [img=15x15]%s[/img]" % [
			stats.dmg, dmg_icon.resource_path]
	
	if stats.get("atk_range"):
		txt += "\n[color=green]range: %s[/color] [img=15x15]%s[/img]" % [
			stats.atk_range, range_icon.resource_path]
	
	if stats.get("knockback"):
		txt += "\n[color=green]knockback: %s[/color] [img=15x15]%s[/img]" % [
			stats.knockback, dist_icon.resource_path]
	
	if stats.get("atk_spd"):
		txt += "\n[color=green]atk_spd: %s[/color] [img=15x15]%s[/img]" % [
			stats.atk_spd, clock_icon.resource_path]
	
	if stats.get("cost"):
		txt += "\n[color=orange]cost: %s[/color] [img=15x15]%s[/img]" % [
			stats.cost, wood_icon.resource_path]
	
	if stats.get("description"):
		txt += "\n[color=yellow][i]%s[/i][/color]" % stats.description
			
	label.text = txt

func _on_mouse_entered():
	theme = highlighted_theme
	tooltip_text = "Click on tower to start building"
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player and stats:
		var player_materials = player.stats.building_materials
		if player_materials < stats.cost:
			tooltip_text = "Not enough building materials"
			theme = blocked_theme

func _on_mouse_exited():
	theme = null

func _input(event):
	if not theme == highlighted_theme:
		return
	if event.is_action_pressed("click"):
		print("clicked on %s" % id)
		clicked.emit(id)
