class_name Particles extends GPUParticles2D

var target: Vector2 = Vector2.ZERO
var disappear_delay: float = 2
var max_squared_gap_to_target: float = 50
var speed: float = 300
var randomizer: float = 1.0

signal arrived
var arrived_signal_sent: bool = false
signal disappeared

func _physics_process(delta):
	if target == Vector2.ZERO:
		return
		
	if global_position.distance_squared_to(target) <= max_squared_gap_to_target:
		if !arrived_signal_sent:
			arrived.emit(self)
			arrived_signal_sent = true
		disappear_delay -= delta
		if disappear_delay <= 0:
			disappeared.emit(self)
			print(str(self) + " disappear")
			queue_free()
		return
	
	
