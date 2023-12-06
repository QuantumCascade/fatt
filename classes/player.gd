class_name Player extends Node

var main_scene: MainScene
var pid: String
var castle: Castle
var mob_idx: int = 0

var mana_limit: float = 100
var mobs_limit: int = 10

var mana: float = 100
var mana_pool: float = 200
var mana_regen: float = 5
var spawn_mana_cost: float = 20
var spawn_cooldown: float = 0 # remaining delta
var spawn_cooldown_val: float = 0.5 # how long to wait after a spawn

var color_mod: Color = Color(0, 0, 0)

var unit_prefab = preload("res://unit.tscn")

var mobs: Array[Unit] = []

func _init(id: String):
	self.pid = id


func _physics_process(delta: float):
	if mana < mana_limit:
		var mana_genered = min(mana_regen, mana_pool) * delta
		mana_pool -= mana_genered
		var newMana = mana + mana_genered
		if newMana > mana_limit:
			newMana = mana_limit
		mana = newMana
	if spawn_cooldown > 0:
		spawn_cooldown -= delta
		if spawn_cooldown < 0:
			spawn_cooldown = 0

func setupCastleAt(position: Vector2) -> Player:
	var res = preload("res://castle.tscn")
	castle = res.instantiate()
	castle.position = position
	castle.master = self
	return self


func attachTo(scene: MainScene) -> Player:
	main_scene = scene
	scene.add_child(castle)
	return self


func can_spawn() -> bool:
	if mana < spawn_mana_cost \
		|| castle.body.hp <= 0 \
		|| spawn_cooldown > 0 \
		|| !castle.spawnArea.get_overlapping_bodies().is_empty() \
		|| mobs.size() >= mobs_limit:
		return false
	return true


func spawnMob() -> Unit:
	if !can_spawn():
		return null
	var mob: Unit = unit_prefab.instantiate()
	mob.position = castle.spawnArea.global_position
	mob.master = self
	mob.id = "unit_" + str(nextMobIdx()) + "@" + pid
	mob.apply_color_mod(color_mod)
	mobs.append(mob)
	mana -= spawn_mana_cost
	spawn_cooldown = spawn_cooldown_val
	return mob

func on_mob_killed(mob: Unit):
	mobs.erase(mob)

func nextMobIdx() -> int:
	mob_idx += 1
	return mob_idx
