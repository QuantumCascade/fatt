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
	return gets("kind", get_game_obj(target))
	

static func gets(prop: String, obj: Node) -> String:
	if prop in obj:
		return obj[prop]
	return ""
	
static func getf(prop: String, obj: Node) -> float:
	if prop in obj:
		return obj[prop]
	return 0


static func calc_dmg(attacker: Node, target: Node):
	var target_armor: float = getf("armor", target)
	var attack_strength: float = getf("attack_strength", attacker)
	var atk = attack_strength * randf_range(0.2, 1.0)
	var blocked_dmg: float = min(target_armor, attack_strength) * randf_range(0.2, 1.0)
	var dmg: float = max(atk - blocked_dmg, 0)
	var armor_dmg: float = blocked_dmg * randf_range(0.2, 1.0)
	return {
		"atk": atk,
		"dmg": dmg,
		"blocked_dmg": blocked_dmg,
		"armor_dmg": armor_dmg,
	}


static func is_attackable_enemy(attacker: Node, target: Node) -> bool:
	return target != null && getf("hp", target) > 0 \
		&& target.has_method("receive_dmg") \
		&& get_pid(target) != get_pid(attacker)

static func get_pid(obj: Node):
	if "pid" in obj:
		return obj.pid
	if obj.has_method("get_pid"):
		return obj.get_pid()
	var parent = obj.get_parent()
	if parent != null:
		return get_pid(parent)
	return "unknown"

# this will have shared seed
static var rnd = RandomNumberGenerator.new()
