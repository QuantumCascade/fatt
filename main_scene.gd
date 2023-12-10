class_name MainScene extends Node2D

const kind = "MainScene"

enum State { PEACE, WAR, WIN, LOOSE }

var players: Dictionary = {}
var player_a: Player
var player_b: Player

var mobs: Array[Unit] = []
var state: State = State.PEACE

var tower_placeholder_pos: Vector2 = Vector2.ZERO

@onready var next_wave_timer: NextWaveTimer = $NextWaveTimer
@onready var tower_placeholder: Node2D = $TowerPlaceholder
@onready var towers_line_1: Curve2D = $TowersLine1.curve
@onready var towers_line_2: Curve2D = $TowersLine2.curve

var phases: Array = [
	{
		"length": 3,
		"spawn_pool_a": 80,
		"spawn_pool_b": 100,
		"party_size_b": 4,
	},
	{
		"length": 30,
		"spawn_pool_a": 160,
		"spawn_pool_b": 360,
		"party_size_b": 6,
	},
	{
		"length": 30,
		"spawn_pool_a": 320,
		"spawn_pool_b": 540,
		"party_size_b": 9,
	},
	{
		"length": 30,
		"spawn_pool_a": 320,
		"spawn_pool_b": 720,
		"party_size_b": 12,
	}
]

func _ready():
	# main player
	add_player(Player.new("a"), $CastleMarker1.position, Color(0, 0, 0))
	player_a = players["a"]
	player_a.stats.build_tower_resource_val = 100
	player_a.stats.build_tower_resource_regen = 5
	player_a.stats.spawn_resource_val = 0
	player_a.stats.spawn_resource_regen_from_pool = 3
	player_a.stats.basic_unit_hp = 70
	player_a.stats.basic_unit_attack_strength = 30
	player_a.stats.basic_unit_armor = 15
	player_a.stats.basic_unit_movement_speed = 100
	player_a.castle.load_texture(1)
	player_a.castle.flip()
	
	# opponent
	add_player(Player.new("b"), $CastleMarker2.position, Color(0, 0, -255))
	player_b = players["b"]
	player_b.stats.spawn_resource_val = 20
	player_b.stats.spawn_resource_regen_from_pool = 5.5
	player_b.stats.basic_unit_hp = 100
	player_b.stats.basic_unit_attack_strength = 45
	player_b.stats.basic_unit_armor = 20
	player_b.stats.basic_unit_movement_speed = 95
	player_b.castle.load_texture(2)

	player_b.enemy = player_a
	player_a.enemy = player_b
	
	swithch_to_peace()


func initWaveTimer(val: int):
	print("next attack in " + str(val) + " sec")
	next_wave_timer.time_to_attack = val

func swithch_to_war():
	state = State.WAR

func swithch_to_peace():
	if phases.is_empty():
		if state != State.WIN:
			state = State.WIN
			print("Win")
		return
	state = State.PEACE
	
	var active_mobs = mobs.filter(is_active_mob)
	for mob: Unit in active_mobs:
		if mob.general_target != mob.master.castle.spawn_area:
			print("send %s to barracks" % mob.getId())
			mob.general_target = mob.master.castle.spawn_area
			mob.set_movement_target(mob.general_target)
	
	var phase_conf = phases.pop_front()
	print("Starting next phase: " + str(phase_conf))
	player_a.stats.spawn_resource_pool = phase_conf.spawn_pool_a
	player_b.stats.spawn_resource_pool = phase_conf.spawn_pool_b
	player_b.stats.gathering_party_count = phase_conf.party_size_b
	initWaveTimer(phase_conf.length)

func _physics_process(_delta):
	var active_mobs = mobs.filter(is_active_mob)
	var player_b_active_mobs = active_mobs.filter(func(u: Unit): return u.get_pid() == "b")
	if player_b_active_mobs.is_empty() && !player_b.has_spawn_potential():
		swithch_to_peace()

func is_active_mob(mob: Unit) -> bool:
	return mob.state == Unit.State.ATTACKING || \
		mob.state == Unit.State.WALKING || \
		mob.state == Unit.State.WAITING

func _input(event: InputEvent):
	var player: Player = players["a"]
	if player.can_build_tower():
		process_tower_placeholder(event)
	else:
		tower_placeholder.hide()

func process_tower_placeholder(event: InputEvent):
	# POC for placing towers without tile data
	var mouse_pos = get_global_mouse_position()
	var p1 = towers_line_1.get_closest_point(mouse_pos)
	var p2 = towers_line_2.get_closest_point(mouse_pos)
	var d1 = mouse_pos.distance_squared_to(p1)
	var d2 = mouse_pos.distance_squared_to(p2)
	var new_tower_placeholder_pos = Vector2.ZERO
	
	if d1 < d2 && d1 < 2500:
		new_tower_placeholder_pos = p1
	elif d2 < 2500:
		new_tower_placeholder_pos = p2
	
	if new_tower_placeholder_pos != Vector2.ZERO:
		# TODO: check if spot is not occupied
		tower_placeholder.position = new_tower_placeholder_pos
		tower_placeholder.show()
	else:
		tower_placeholder.hide()
		tower_placeholder_pos = Vector2.ZERO

	if event.is_action_pressed("click") && new_tower_placeholder_pos != Vector2.ZERO:
		tower_placeholder_pos = new_tower_placeholder_pos
		var builder_menu_prefab = preload("res://build_tower_menu.tscn")
		var builder_menu = builder_menu_prefab.instantiate()
		builder_menu.position = tower_placeholder_pos
		var scr_size = get_viewport().get_visible_rect().size
		if (builder_menu.position.x + builder_menu.size.x) > scr_size.x:
			builder_menu.position.x -= builder_menu.size.x
		if (builder_menu.position.y + builder_menu.size.y) > scr_size.y:
			builder_menu.position.y -= builder_menu.size.y
		builder_menu.build_tower_confirmed.connect(on_build_tower_confirmed)
		builder_menu.build_tower_selected.connect(on_build_tower_selected)
		add_child(builder_menu)

func on_build_tower_selected(id: int):
	print("Tower selected: %d", id)
	# TODO: update placeholder sprite

#TODO: Allow to delete confirmed placeholder if tower js not finished yet
func on_build_tower_confirmed(id: int):
	print("Tower id=%d confirmed at %s" % [id, tower_placeholder_pos])
	if tower_placeholder_pos == Vector2.ZERO:
		print_debug("ERR: lost the placeholder pos")
		return
	var player: Player = players["a"]
	var tower: Tower = player.build_tower(tower_placeholder_pos, id)
	if tower != null:
		tower.operator_inside_tower.connect(on_operator_inside_tower)
	tower_placeholder_pos = Vector2.ZERO

func on_operator_inside_tower(mob: Unit):
	mobs.erase(mob)

func on_mob_killed(killedMob: Unit):
	mobs.erase(killedMob)
	print("burying mob: " + killedMob.getId())


func add_player(player: Player, castlePosition: Vector2, colorMod: Color):
	player.main_scene = self
	players[player.pid] = player.setup_castle_at(castlePosition)
	player.color_mod = colorMod
	add_child(player)
	add_child(player.castle)
	return player

func spawned_mob(mob: Unit):
	mobs.append(mob)
	add_child(mob)
	mob.killed.connect(on_mob_killed)
	print("spawned: " + str(mob))
