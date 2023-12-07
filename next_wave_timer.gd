class_name NextWaveTimer extends Label

const PREFIX = "Next wave in: "
const POSTFIX = " seconds"

var val: float = -1

@onready var main_scene: MainScene = get_parent()

func _process(delta):
	if val < 0:
		return
	if val > 0:
		val = val - delta
		if val < 0:
			val = 0
		text = PREFIX + str(ceil(val)) + POSTFIX
	else:
		val = -1
		main_scene.swithch_to_war()
		text = "Attack mode"
		main_scene.spawnMobs()
