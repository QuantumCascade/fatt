class_name MainScene extends Node2D

const kind = "MainScene"

var players: Dictionary = {}
var mobs: Array[Unit] = []
var state: String = PEACE

const PEACE = "peace"
const WAR = "war"

var tile_bkp_pos: Vector2i
var tower_to_build_id: int = -1

@onready var next_wave_timer: NextWaveTimer = $NextWaveTimer
@onready var tile_map = $TileMap


func _ready():
	addPlayer(Player.new("a"), Vector2(85, 50), Color(0, 0, 0)).mana = 20
	addPlayer(Player.new("b"), Vector2(1320, 810), Color(0, 0, -255))
	initWaveTimer(2)
	
func initWaveTimer(val: int):
	print("next wave in " + str(val) + " sec")
	next_wave_timer.val = val

func _physics_process(delta: float):
	for pid in players:
		players[pid]._physics_process(delta)
	if !mobs.is_empty():
		if state != WAR:
			state = WAR
			print("Switching to war state")

	if state == WAR && mobs.is_empty():
		print("Switching to peace")
		state = PEACE
		initWaveTimer(5)
		
	if state == WAR:
		spawnMobs()

func if_tile_for_tower() -> Vector2i:
	var cell: Vector2i = tile_map.local_to_map(tile_map.get_local_mouse_position())
	var data = tile_map.get_cell_tile_data(0, cell)
	if data && data.get_custom_data("twr_places"):
		return cell
	else:
		return Vector2i.MIN


func _input(event: InputEvent):
	
	# POC for placing towers without tile data
	#var mouse_pos = get_global_mouse_position()
	#var p = $Path2D.curve.get_closest_point(mouse_pos)
	#var p2 = $Path2D2.curve.get_closest_point(mouse_pos)
	#var d1 = mouse_pos.distance_squared_to(p)
	#var d2 = mouse_pos.distance_squared_to(p2)
	#if d1 < d2:
		#if d1 < 2500:
			#$Sprite2D.position = p
			#$Sprite2D.show()
		#else:
			#$Sprite2D.hide()
	#elif d2 < 2500:
		#$Sprite2D.position = p2
		#$Sprite2D.show()
	#else:
		#$Sprite2D.hide()

	var tile_coord = if_tile_for_tower()
	if tile_coord != Vector2i.MIN:
		$TowerPlaceholder.position = tile_map.map_to_local(tile_coord)
		$TowerPlaceholder.show()
		if event.is_action_pressed("click"):
			tile_bkp_pos = tile_coord
			var builderMenuPrefab = preload("res://build_tower_menu.tscn")
			var builder_menu = builderMenuPrefab.instantiate()
			builder_menu.position = tile_map.map_to_local(tile_coord)
			var scr_size = get_viewport().get_visible_rect().size
			if (builder_menu.position.x + builder_menu.size.x) > scr_size.x:
				builder_menu.position.x -= builder_menu.size.x
			if (builder_menu.position.y + builder_menu.size.y) > scr_size.y:
				builder_menu.position.y -= builder_menu.size.y
			builder_menu.build_tower_confirmed.connect(on_build_tower_confirmed)
			builder_menu.build_tower_selected.connect(on_build_tower_selected)
			add_child(builder_menu)
	else:
		$TowerPlaceholder.hide()


func on_build_menu_closed():
	tower_to_build_id = -1

func on_build_tower_selected(id: int):
	print("Tower selected: " + str(id))
	# TODO: just show shadow

func on_build_tower_confirmed(id: int):
	print("Tower confirmed: " + str(id) + "@" + str(tile_bkp_pos))
	tower_to_build_id = id
	if tile_bkp_pos != Vector2i.MIN:
		var placement: Vector2 = tile_map.map_to_local(tile_bkp_pos)
		var towerPrefab = preload("res://tower.tscn")
		var tower: Tower = towerPrefab.instantiate()
		tower.global_position = placement
		tower.master = players["a"]
		add_child(tower)
		# TODO: instantiate the tower

func on_mob_killed(killedMob: Unit):
	mobs.erase(killedMob)
	print("burying mob: " + killedMob.getId())

func addPlayer(player: Player, castlePosition: Vector2, colorMod: Color):
	players[player.pid] = player.setupCastleAt(castlePosition).attachTo(self)
	player.color_mod = colorMod
	player.castle.apply_color_mod(colorMod)
	return player


func spawnMobs():
	for pid in players:
		var player: Player = players[pid]
		if player.can_spawn():
			var opponent: Player = getOpponent(pid)
			var unit: Unit = player.spawnMob()
			if unit != null:
				unit.general_target = opponent.castle
				mobs.append(unit)
				add_child(unit)
				unit.killed.connect(on_mob_killed)
				print("spawned: " + str(unit))



func getOpponent(pid: String) -> Player:
	for id in players:
		if id != pid:
			return players[id]
	return null
