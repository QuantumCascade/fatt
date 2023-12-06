class_name Util extends Node

static func get_game_obj(target: Node):
	if target == null:
		return null
	if "kind" in target:
		return target
	if "kind" in target.get_parent():
		return target.get_parent()
	return target

static func get_kind(target: Node) -> String:
	if target == null:
		return "null"
	return get_game_obj(target).kind

static func gets(prop: String, obj: Node) -> String:
	if prop in obj:
		return obj[prop]
	return ""
	
static func getf(prop: String, obj: Node) -> float:
	if prop in obj:
		return obj[prop]
	return 0


static func calc_dmg(attacker: Node, target: Node) -> float:
	var targetArmor: float = getf("armor", target)
	var attack_strength: float = getf("attack_strength", attacker)
	attack_strength = attack_strength * randf_range(0.25, 1.00)
	var dmg: float = attack_strength - targetArmor
	return dmg


static func is_attackable_enemy(attacker: Node, target: Node) -> bool:
	return target != null && getf("hp", target) > 0 \
		&& target.has_method("receive_dmg") \
		&& get_pid(target) != get_pid(attacker)

static func get_pid(obj: Node):
	if "pid" in obj:
		return obj.pid
	if obj.has_method("get_pid"):
		return obj.get_pid()
	return "unknown"

# this will have shared seed
static var rnd = RandomNumberGenerator.new()
