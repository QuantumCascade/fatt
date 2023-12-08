class_name MainScene extends Node2D

const kind = "MainScene"

enum State { PEACE, WAR }

var players: Dictionary = {}
var mobs: Array[Unit] = []
var state: State = State.PEACE

#var tile_bkp_pos: Vector2i
var tower_placeholder_pos: Vector2 = Vector2.ZERO
var tower_to_build_id: int = -1

@onready var next_wave_timer: NextWaveTimer = $NextWaveTimer
@onready var tower_placeholder: Node2D = $TowerPlaceholder
@onready var towers_line_1: Curve2D = $TowersLine1.curve
@onready var towers_line_2: Curve2D = $TowersLine2.curve


func _ready():
	# main player
	add_player(Player.new("a"), $CastleMarker1.position, Color(0, 0, 0))
	players["a"].stats.spawn_resource_val = 0
	players["a"].stats.basic_unit_hp = 100
	players["a"].castle.load_texture(1)
	players["a"].castle.flip()
	
	# opponent
	add_player(Player.new("b"), $CastleMarker2.position, Color(0, 0, -255))
	players["b"].stats.spawn_resource_val = 100
	players["b"].stats.spawn_resource_regen_from_pool = 5
	players["b"].stats.basic_unit_hp = 80
	players["b"].castle.load_texture(2)

	players["a"].enemy = players["b"]
	players["b"].enemy = players["a"]
	
	initWaveTimer(2)


func initWaveTimer(val: int):
	print("next attack in " + str(val) + " sec")
	next_wave_timer.time_to_attack = val

func swithch_to_war():
	state = State.WAR

#func _physics_process(delta: float):

	#if !mobs.is_empty():
		#if state != State.WAR:
			#state = State.WAR
			#print("Switching to war state")
#
	#if state == State.WAR && mobs.is_empty():
		#print("Switching to peace")
		#state = State.PEACE
		#initWaveTimer(5)
		
	#if state == State.WAR:
		#spawn_mobs()

#func if_tile_for_tower() -> Vector2i:
	#var cell: Vector2i = tile_map.local_to_map(tile_map.get_local_mouse_position())
	#var data = tile_map.get_cell_tile_data(0, cell)
	#if data && data.get_custom_data("twr_places"):
		#return cell
	#else:
		#return Vector2i.MIN


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
			
	#var tile_coord = if_tile_for_tower()
	#if tile_coord != Vector2i.MIN:
		#$TowerPlaceholder.position = tile_map.map_to_local(tile_coord)
		#$TowerPlaceholder.show()
		#if event.is_action_pressed("click"):
			#tile_bkp_pos = tile_coord
			#var builderMenuPrefab = preload("res://build_tower_menu.tscn")
			#var builder_menu = builderMenuPrefab.instantiate()
			#builder_menu.position = tile_map.map_to_local(tile_coord)
			#var scr_size = get_viewport().get_visible_rect().size
			#if (builder_menu.position.x + builder_menu.size.x) > scr_size.x:
				#builder_menu.position.x -= builder_menu.size.x
			#if (builder_menu.position.y + builder_menu.size.y) > scr_size.y:
				#builder_menu.position.y -= builder_menu.size.y
			#builder_menu.build_tower_confirmed.connect(on_build_tower_confirmed)
			#builder_menu.build_tower_selected.connect(on_build_tower_selected)
			#add_child(builder_menu)
	#else:
		#$TowerPlaceholder.hide()


func on_build_menu_closed():
	tower_to_build_id = -1

func on_build_tower_selected(id: int):
	print("Tower selected: " + str(id))
	# TODO: show shadow of selected

func on_build_tower_confirmed(id: int):
	print("Tower confirmed: " + str(id) + "@" + str(tower_placeholder_pos))
	tower_to_build_id = id
	if tower_placeholder_pos == Vector2.ZERO:
		return
	var player: Player = players["a"]
	var towerPrefab = preload("res://tower.tscn")
	var tower: Tower = towerPrefab.instantiate()
	if !player.paid_for_tower(tower):
		print("Error! Not ehough wood to build a tower")
		tower_placeholder_pos = Vector2.ZERO
		tower.queue_free()
		return
	tower.global_position = tower_placeholder_pos
	tower.master = player
	add_child(tower)
	tower.shadow()
	tower_placeholder_pos = Vector2.ZERO


func on_mob_killed(killedMob: Unit):
	mobs.erase(killedMob)
	print("burying mob: " + killedMob.getId())

func add_player(player: Player, castlePosition: Vector2, colorMod: Color):
	player.main_scene = self
	players[player.pid] = player.setupCastleAt(castlePosition)
	player.color_mod = colorMod
	add_child(player)
	add_child(player.castle)
	return player

func spawned_mob(mob: Unit):
	mobs.append(mob)
	add_child(mob)
	mob.killed.connect(on_mob_killed)
	print("spawned: " + str(mob))

#func spawn_mobs():
	#for pid in players:
		#var player: Player = players[pid]
		#if player.can_spawn():
			#var opponent: Player = getOpponent(pid)
			#var unit: Unit = player.spawnMob()
			#if unit != null:
				#unit.enemy_castle = opponent.castle
				#mobs.append(unit)
				#add_child(unit)
				#unit.killed.connect(on_mob_killed)
				#print("spawned: " + str(unit))



#func getOpponent(pid: String) -> Player:
	#for id in players:
		#if id != pid:
			#return players[id]
	#return null
