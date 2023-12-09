class_name Player extends Node

var pid: String
var main_scene: MainScene
var castle: Castle
var enemy: Player
var mob_idx: int = 0

var mana_limit: float = 100
var mobs_limit: int = 10

var stats: PlayerStats = PlayerStats.new()

var spawn_cooldown: float = 0 # remaining delta
var spawn_cooldown_val: float = 0.1 # how long to wait after a spawn

var color_mod: Color = Color(0, 0, 0)

var unit_prefab: Resource = preload("res://unit.tscn")

var mobs: Array[Unit] = []
var building_orders: Array[Tower] = []

func _init(id: String):
	self.pid = id

func _physics_process(delta: float):
	if castle.state == Castle.State.DESTROYED:
		return
		
	stats.regen_spawn_resource(delta)
	
	if spawn_cooldown > 0:
		spawn_cooldown -= delta
		if spawn_cooldown < 0:
			spawn_cooldown = 0
	
	if main_scene.state == MainScene.State.WAR:
		if can_spawn():
			spawn_mob()
	elif main_scene.state == MainScene.State.PEACE:
		if check_pending_buildings() != null && can_spawn():
			spawn_mob()

func setup_castle_at(position: Vector2) -> Player:
	var res = preload("res://castles/castle.tscn")
	castle = res.instantiate()
	castle.position = position
	castle.master = self
	return self

func can_build_tower() -> bool:
	return stats.build_tower_resource_val >= stats.build_tower_cost

func build_tower(tower_pos: Vector2, tower_id: int) -> Tower:
	var tower: Tower = preload("res://tower.tscn").instantiate()
	if !paid_for_tower(tower, tower_id):
		print("Error! Not ehough wood to build a tower %d" % tower_id)
		tower.queue_free()
		return null
	tower.global_position = tower_pos
	tower.master = self
	add_child(tower)
	tower.shadow()
	tower.missing_operator.connect(on_tower_missing_operator)
	tower.operator_inside_tower.connect(on_operator_inside_tower)
	return tower

func on_tower_missing_operator(tower: Tower):
	if !building_orders.has(tower):
		print(pid + "# received call to build " + str(tower))
		building_orders.append(tower)

func on_operator_inside_tower(mob: Unit):
	mobs.erase(mob)
	
func paid_for_tower(_tower: Tower, _tower_id: int) -> bool:
	if stats.build_tower_resource_val >= stats.build_tower_cost:
		stats.build_tower_resource_val -= stats.build_tower_cost
		return true
	return false

func can_spawn() -> bool:
	#var reason = ""
	if stats.spawn_resource_val < stats.spawn_cost:
		#reason += "/ mana=" + str(mana) + " but cost=" + str(spawn_mana_cost)
		return false
	if castle.body.hp <= 0:
		#reason += "/ castle_hp=" + str(castle.body.hp)
		return false
	if spawn_cooldown > 0:
		#reason += "/ spawn_cooldown=" + str(spawn_cooldown)
		return false
	if castle.any_unit_in_spawn_area():
		#reason += "/occupied_zone=" + str(castle.spawnArea.get_overlapping_bodies())
		return false
	if mobs.size() >= mobs_limit:
		#reason += "/mobs=" + str(mobs.size()) + " but limit="+str(mobs_limit)
	#if reason != "":
		#print(pid + "# can not spawn:" + reason)
		return false
	return true


func spawn_mob() -> Unit:
	if !can_spawn():
		return null
	var mob: Unit = unit_prefab.instantiate()
	mob.position = castle.spawn_area.global_position
	mob.master = self
	mob.init_stats(stats)
	mob.id = "unit_" + str(nextMobIdx()) + "@" + pid
	mob.apply_color_mod(color_mod)
	mobs.append(mob)
	if pid == "b":
		mob.use_alt_anim()
	stats.spawn_resource_val -= stats.spawn_cost
	spawn_cooldown = spawn_cooldown_val
	mob.enemy_castle = enemy.castle
	main_scene.spawned_mob(mob)
	var pending_twr: Tower = check_pending_buildings()
	if pending_twr != null:
		print("assigned %s as operator for %s" % [mob.getId(), pending_twr.getId()])
		pending_twr.set_operator(mob)
		mob.operating_tower = pending_twr
	return mob



func check_pending_buildings() -> Tower:
	if building_orders.is_empty():
		return null
	# find a tower building order without assigned operator
	var non_operable = building_orders.filter(func(t: Tower): return t.operator == null)
	if non_operable.is_empty():
		return null
	return non_operable[0]

func get_spawn_potential() -> float:
	return stats.spawn_resource_val + stats.spawn_resource_pool

# Returns true if player can spawn a mob now or when spawn resource regenerated.
# If spawn resource depleted and current value is not enough to spawn a mob then return false.
func has_spawn_potential() -> bool:
	if get_spawn_potential() < stats.spawn_cost:
		return false
	return true
	
func on_mob_killed(mob: Unit):
	mobs.erase(mob)


func nextMobIdx() -> int:
	mob_idx += 1
	return mob_idx
