class_name MobSprite
extends Sprite2D

static var noise_dict: Dictionary = {}

signal attack_animation_performed # moment when attack hits target
signal attack_animation_complete # attack animation finished
signal death_animation_performed

signal animation_complete

var dissolving: float = -1


func gen_noise(size: Vector2):
	var noise_texture: NoiseTexture2D = NoiseTexture2D.new()
	noise_texture.width = int(size.x)
	noise_texture.height = int(size.y)
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise_texture.noise = noise
	var pool: Array = noise_dict.get(size, [])
	pool.append(noise_texture)
	noise_dict[size] = pool


func dissolve(delta: float) -> float:
	if dissolving < 0:
		var size: Vector2 = self.texture.get_size()
		if noise_dict.get(size, []).size() < 3:
			print("gen noise for %s" % [size])
			gen_noise(size)
		var shader_material: ShaderMaterial = ShaderMaterial.new()
		shader_material.shader = preload("res://shaders/dissolve.gdshader")
		var pool: Array = noise_dict[texture.get_size()]
		var noise_texture: NoiseTexture2D = pool[randi_range(0, pool.size() - 1)] as NoiseTexture2D
		shader_material.set_shader_parameter("noise_texture", noise_texture)
		dissolving = 1
		material = shader_material
	dissolving = max(dissolving - delta, 0)
	if dissolving >= 0:
		(material as ShaderMaterial).set_shader_parameter("value", dissolving)
	return dissolving


func play(_anim_name: String) -> void:
	pass


func flip_to(target: Vector2):
	if target.x < 0:
		if not is_flipped_h():
			flip_h = true
	else:
		if is_flipped_h():
			flip_h = false


func _on_attack_animation_complete() -> void:
	attack_animation_complete.emit()

func _on_attack_animation_performed() -> void:
	attack_animation_performed.emit()

func _on_death_animation_performed() -> void:
	death_animation_performed.emit()
