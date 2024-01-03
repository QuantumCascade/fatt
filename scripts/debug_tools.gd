class_name Debug


static func draw_marker_at(pos: Vector2, scene_tree: SceneTree):
	var line: Line2D = Line2D.new()
	line.add_point(pos - Vector2.ONE * 2)
	line.add_point(pos + Vector2.ONE * 2)
	line.width = 1
	scene_tree.current_scene.add_child(line)
	var line2: Line2D = Line2D.new()
	line2.add_point(pos - Vectors.up_right * 2)
	line2.add_point(pos + Vectors.up_right * 2)
	line2.width = 1
	scene_tree.current_scene.add_child(line2)
