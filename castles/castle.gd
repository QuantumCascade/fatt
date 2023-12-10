class_name Castle extends Node2D

const kind = "Castle"

enum State { WAITING, DESTROYED }

@export var vision_range: float = 300
@export var attack_range: float = 10
@export var state: State = State.WAITING
@export var master: Player
@export var pid: String = "?"

@export var recharge_cooldown_val: float = 4
@export var attack_cooldown_val: float = 0.5
@export var attack_strength: float = 50
@export var max_charges = 3

@export var max_hp: float = 300
@export var hp: float = 300
@export var armor: float = 30

var charges = max_charges
var recharge_cooldown: float = 0
var attack_cooldown: float = 0

var enemies_in_range: Array[Unit] = []

var projectile_prefab = preload("res://projectiles/projectile.tscn")

@onready var spawn_area: Area2D = $SpawnArea

func _ready():
	$HpBar.max_value = hp
	$HpBar.value = hp
	$HpBar.visible = false
	print("%s spawned at %s" % [getId(), position])

func set_master(player: Player):
	self.master = player
	self.pid = player.get_pid()

func flip():
	$Sprite2D.flip_h = true
	spawn_area.position.x = -1 * spawn_area.position.x

func load_texture(n: int):
	if n == 1:
		var img: Texture2D = load("res://sprites/buildings/castle-1.png")
		$Sprite2D.set_texture(img)
	elif n == 2:
		var img: Texture2D = load("res://sprites/buildings/castle-2.webp")
		$Sprite2D.set_texture(img)

func _physics_process(delta: float):
	if hp <= 0 && state != State.DESTROYED:
		state = State.DESTROYED
		$DestroyedSfx.pitch_scale = randf_range(0.8, 1.2)
		$DestroyedSfx.play()
		print(getId() + " destroyed!")
		
	if state == State.DESTROYED:
		return
	
	regen_cooldowns(delta)
	
	enemies_in_range = enemies_in_range.filter(func(e): return Util.is_attackable_enemy(self, e))
	
	if !enemies_in_range.is_empty() && attack_cooldown <= 0 && charges > 0:
		var a_target = enemies_in_range[0]
		var projectile: Projectile = projectile_prefab.instantiate()
		var launch_pos = self.global_position
		launch_pos.y -= 100 # shooting from the highest point # TODO: add marker
		projectile.global_position = launch_pos
		projectile.target = a_target
		projectile.attack_strength = 75.0
		projectile.arc_height = 100.0
		get_parent().add_child(projectile)
		var predicted_target_pos = a_target.get_pos_after(1) # TODO: fix 
		projectile.launch(self, predicted_target_pos)
		print(getId() + " shoot to >> " + str(a_target))
		charges -= 1
		attack_cooldown = attack_cooldown_val
		if recharge_cooldown == 0:
			recharge_cooldown = recharge_cooldown_val
	
	for overlapping in spawn_area.get_overlapping_areas():
		process_body_in_spawn_area(get_area_body(overlapping))

func get_area_body(area: Area2D):
	return area.get_parent()

func regen_cooldowns(delta: float):
	if attack_cooldown > 0:
		attack_cooldown -= min(attack_cooldown, delta)
	
	if recharge_cooldown > 0:
		recharge_cooldown -= min(recharge_cooldown, delta)
		if recharge_cooldown == 0:
			print(getId() + " Recharged! n=" + str(max_charges))
			charges = max_charges

func any_unit_in_spawn_area() -> bool:
	return spawn_area.get_overlapping_bodies().any(func(obj): return Util.get_kind(obj) == "Unit")

func apply_color_mod(color_mod: Color):
	$Sprite2D.modulate = $Sprite2D.modulate + color_mod


func receive_dmg(dmg: Dictionary, attacker: Node):
	var hp_before = hp
	hp = max(hp - dmg.dmg, 0)
	print("%s received %s from %s ~ hp: %s -> %s" % [getId(), dmg, attacker.getId(), hp_before, hp])
	$HpBar.value = hp
	$HpBar.visible = true
	if hp/$HpBar.max_value < 0.5:
		$HpBar.modulate = Color.RED

func getId() -> String:
	return "castle@" + get_pid()
	
func get_pid() -> String:
	if master == null:
		return pid
	return master.pid

func _to_string():
	return "%s | hp=" % [getId(), hp]


func _on_attack_area_area_entered(area):
	_on_attack_area_body_entered(area.get_parent())

func _on_attack_area_body_entered(target):
	if Util.is_attackable_enemy(self, target):
		print(getId() + " i see >> " + str(target))
		enemies_in_range.append(target)


func _on_attack_area_body_exited(body_exited):
	if Util.get_kind(body_exited) == "Unit":
		enemies_in_range.erase(body_exited)


func process_body_in_spawn_area(body):
	if master.main_scene.state != MainScene.State.PEACE:
		return
	if Util.get_kind(body) != "Unit":
		return
	var unit: Unit = body as Unit
	if unit.get_pid() != self.get_pid():
		return
	if unit.operating_tower != null:
		return
	# load units into barrack
	master.stats.regen_spawn_for_unit(unit)
	unit.erase_from_parents()

