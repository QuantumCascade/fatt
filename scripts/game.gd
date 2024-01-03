class_name Game
extends Node2D

enum WorldState { PEACE, WAR, WIN, LOOSE }

var state: WorldState = WorldState.PEACE

@onready var builder_assistant: BuilderAssistant = %BuilderAssistant
@onready var builder_menu: BuildTowerMenu = %BuilderMenu
@onready var map: Map = %Map
@onready var music_controller: MusicController = %MusicController
@onready var player: Player = %Player
@onready var status_panel: StatusPanal = %StatusPanel


var peace_time: float
var waves: Array = []


func _ready():
	music_controller.midi_player.play()
	map.pointed_tower_lane_pos.connect(builder_assistant._on_pointed_tower_lane_pos)
	builder_assistant.tower_pos_chosen.connect(builder_menu.popup_at)
	builder_menu.build_tower_confirmed.connect(player.build_tower)
	player.tower_collision_changed.connect(func(_tower): map.reprocess_navigation_region(self))
	init_next_phase()


func _physics_process(delta: float):
	status_panel.update_vals({
		"population": player.stats.population,
		"builders": player.calc_minions("builder"),
	})
	match state:
		WorldState.PEACE:
			peace_time = max(peace_time - delta, 0)
			if peace_time == 0:
				switch_state(WorldState.WAR)
		WorldState.WAR:
			var creeps: Array = get_tree().get_nodes_in_group("enemy_mobs")
			if creeps.is_empty():
				if waves.is_empty():
					print("that was final wave")
					init_next_phase()
					return
				var wave: Dictionary = waves.pop_front()
				print("spawn next wave: %s" % wave)
				for creep_name in wave:
					var count: int = wave.get(creep_name)
					var enemy: Enemy = get_tree().get_first_node_in_group("enemy") as Enemy
					for i in range(count):
						enemy.spawn_queue.append(creep_name)
	


func switch_state(new_state: WorldState):
	print("%s -> %s" % [state, new_state])
	state = new_state


func init_next_phase():
	if phases.is_empty():
		state = WorldState.WIN
		print("Player won!")
		return
	var phase_conf: Dictionary = phases.pop_front()
	peace_time = phase_conf.get("peace_duration")
	switch_state(WorldState.PEACE)
	waves = phase_conf.get("waves")


var phases: Array = [
	{
		"peace_duration": 3,
		"waves": [
			{
				"snake": 3
			},
			{
				"snake": 5
			},
			{
				"snake": 10
			}
		]
	}
]
