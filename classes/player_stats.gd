class_name PlayerStats

# this is what player gets for the whole match
var spawn_resource_pool: float = 500

# how much to get from pool to refill current val
var spawn_resource_regen_from_pool: float = 3

# current value
var spawn_resource_val: float = 100

# max val
var spawn_resource_limit: float = 100

# how much to spawn a unit
var spawn_cost: float = 20


var build_tower_resource_val: float = 50
var build_tower_resource_limit: float = 200
var build_tower_resource_regen: float = 2
var build_tower_cost: float = 100

var basic_unit_hp: float = 100


func regen_spawn_resource(delta: float):
	var to_regen: float = spawn_resource_limit - spawn_resource_val
	if to_regen <= 0:
		return
	var available: float = min(spawn_resource_regen_from_pool, spawn_resource_pool) * delta
	to_regen = min(to_regen, available)
	spawn_resource_val += to_regen
	spawn_resource_pool -= to_regen
	regen_building_resource(delta)


func regen_building_resource(delta: float):
	var to_regen: float = build_tower_resource_limit - build_tower_resource_val
	if to_regen <= 0:
		return
	build_tower_resource_val += build_tower_resource_regen * delta


func txt_spawn_pool_remainings() -> String:
	var remainings = floor(spawn_resource_pool / spawn_cost)
	if remainings < 1:
		return txt_spawn_pool_resource_exhausted()
	return "%s conscripts in reserve" % str(remainings)

func txt_spawn_pool_resource_exhausted() -> String:
	return "We're out of conscript reserve"

func txt_spawn_reserve_report(player: Player) -> String:
	var spawn_single_unit_percent = min(fmod(spawn_resource_val, spawn_cost) / spawn_cost, 1)
	if spawn_single_unit_percent < 1 && spawn_resource_pool < spawn_cost:
		if player.mobs.size() == 0:
			return "Nobody is going to fight - no people left"
		else:
			return "Let's hope those remaining fighters can with this battle"
	else:
		return "Training a fighter: %d%%" % ceil(spawn_single_unit_percent * 100)

func txt_spawn_readiness() -> String:
	var ready_cnt: int = floor(spawn_resource_val / spawn_cost)
	if ready_cnt == 0:
		return "Barracks are empty - no fighters ready for battle"
	if spawn_resource_val == spawn_resource_limit:
		return "Barracks are full - we have %s fighters ready for battle" % ready_cnt
	elif ready_cnt > 1:
		return "We have %s fighters in barracs ready for battle" % ready_cnt
	else:
		return "We have only 1 fighter in barracs ready for battle"


func txt_building_resource_report() -> String:
	var perc = build_tower_resource_val / build_tower_cost
	var to_collect = build_tower_resource_limit - build_tower_resource_val
	var txt_collect = "The wood stock is full"
	if to_collect > 0:
		txt_collect = "Collecting more: %d/%d" % [fmod(build_tower_resource_val, build_tower_cost), build_tower_cost]
	if perc >= 2:
		return ("We have enough wood to build %d towers. " % perc) + txt_collect
	elif perc >= 1:
		return "We have enough wood to build a tower. " + txt_collect
	else:
		return "Not enough wood to build a tower. " + txt_collect
