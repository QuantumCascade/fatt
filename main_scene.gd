class_name MainScene extends Node2D

const kind = "MainScene"

var players: Dictionary = {}
var mobs: Array[Unit] = []
var state: String = PEACE

const PEACE = "peace"
const WAR = "war"

const TWR_HLT_ATLAS = Vector2i(6, 7)
const TWR_PLACEHOLDERS: Array[Vector2i] = [\
	Vector2i(1, 3), \
	Vector2i(0, 4), \
	Vector2i(2, 4), \
	Vector2i(1, 5)]
var hover_tile_pos: Vector2i
var tile_bkp_pos: Vector2i
var tile_bkp_atlas: Vector2i = Vector2i.MIN

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

func _input(event: InputEvent):
	var mouse_pos = get_global_mouse_position()
	var pointed_tile_pos = tile_map.local_to_map(mouse_pos)
	if hover_tile_pos != pointed_tile_pos:
		#print("Tile: " + str(pointed_tile_pos))
		if tile_bkp_atlas != Vector2i.MIN:
			tile_map.set_cell(0, tile_bkp_pos, 0, tile_bkp_atlas)
			tile_bkp_atlas = Vector2i.MIN
		hover_tile_pos = pointed_tile_pos
		var pointed_tile_atlas = tile_map.get_cell_atlas_coords(0, pointed_tile_pos)
		if TWR_PLACEHOLDERS.has(pointed_tile_atlas):
			#print("Placeholder: " + str(pointed_tile_atlas))
			tile_bkp_pos = hover_tile_pos
			tile_bkp_atlas = tile_map.get_cell_atlas_coords(0, hover_tile_pos)
			tile_map.set_cell(0, hover_tile_pos, 0, TWR_HLT_ATLAS)
	if event.is_action_pressed("click"):
		var pointed_tile_atlas = tile_map.get_cell_atlas_coords(0, pointed_tile_pos)
		if pointed_tile_atlas == TWR_HLT_ATLAS:
			print("click on placeholder")
			var builderMenuPrefab = preload("res://build_tower_menu.tscn")
			var builder_menu = builderMenuPrefab.instantiate()
			builder_menu.position = mouse_pos
			var scr_size = get_viewport().get_visible_rect().size
			print("Display + " + str(scr_size))
			if (builder_menu.position.x + builder_menu.size.x) > scr_size.x:
				builder_menu.position.x -= builder_menu.size.x
			if (builder_menu.position.y + builder_menu.size.y) > scr_size.y:
				builder_menu.position.y -= builder_menu.size.y
				


			builder_menu.build_tower_confirmed.connect(on_build_tower_confirmed)
			builder_menu.build_tower_selected.connect(on_build_tower_selected)
			add_child(builder_menu)
			
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
