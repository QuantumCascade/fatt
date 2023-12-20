class_name Game
extends Node2D

enum WorldState { PEACE, WAR, WIN, LOOSE }


@onready var builder_assistant: BuilderAssistant = $BuilderAssistant
@onready var builder_menu: BuildTowerMenu = $BuilderMenu
@onready var camera_2d = $Camera2D
@onready var map: Map = $Map
@onready var music_controller: MusicController = $MusicController
@onready var player: Player = $Player


func _ready():
	music_controller.midi_player.play()
	map.pointed_tower_lane_pos.connect(builder_assistant._on_pointed_tower_lane_pos)
	builder_assistant.tower_pos_chosen.connect(builder_menu.popup_at)
	builder_menu.build_tower_confirmed.connect(player.build_tower)
	player.tower_collision_changed.connect(func(_tower): map.reprocess_navigation_region(self))
