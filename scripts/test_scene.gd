extends Node2D


@onready var mob: Mob = $Builder
@onready var nav_region: NavigationRegion2D = $NavigationRegion2D

@onready var navigation_obstacle_1: NavigationObstacle2D = $Tower/NavigationObstacle2D


func _ready():
	($Tower as Tower).setup(GameStats.tower_stats[0].clone())
	
	var new_navigation_mesh: NavigationPolygon = NavigationPolygon.new()
	new_navigation_mesh.cell_size = nav_region.navigation_polygon.cell_size
	new_navigation_mesh.agent_radius = nav_region.navigation_polygon.agent_radius
	
	var navigation_polygon: NavigationPolygon = nav_region.navigation_polygon
	for outline in navigation_polygon.outlines.slice(0, 2):
		print("add orig outline %s" % [outline])
		new_navigation_mesh.add_outline(outline)
	
	for outline in parse_2d_collisionshapes(self):
		print("add new outline %s" % [outline])
		new_navigation_mesh.add_outline(outline)
	
	var callback: Callable = func():
		_set_nav_mesh(new_navigation_mesh)
	
	NavigationServer2D.bake_from_source_geometry_data(new_navigation_mesh, \
		NavigationMeshSourceGeometryData2D.new(), callback)

func _set_nav_mesh(new_poly: NavigationPolygon):
	print("baked mesh: %s" % [new_poly])
	for outline in new_poly.outlines:
		print(">> %s" % [outline])
	NavigationServer2D.region_set_navigation_polygon(nav_region.get_region_rid(), new_poly)
	nav_region.navigation_polygon = new_poly
	#nav_region.bake_navigation_polygon()

func _input(event):
	if event.is_action_pressed("click"):
		print("click %s" % get_global_mouse_position())
		mob.movement_target = get_global_mouse_position()


func parse_2d_collisionshapes(root_node: Node, outlines: Array[PackedVector2Array] = []) -> Array[PackedVector2Array]:
	for node in root_node.get_children():
		if node is Node and node.get_child_count() > 0:
			parse_2d_collisionshapes(node, outlines)
		if node is NavigationObstacle2D:
			var obstacle: NavigationObstacle2D = node as NavigationObstacle2D
			var obstacle_transform: Transform2D = obstacle.get_global_transform()
			var collisionpolygon: PackedVector2Array = obstacle.vertices
			var new_collision_outline: PackedVector2Array = obstacle_transform * collisionpolygon
			print("found nav obstacle %s" % [new_collision_outline])
			outlines.append(new_collision_outline)
		elif node is CollisionPolygon2D:
			var collision_poly: CollisionPolygon2D = node as CollisionPolygon2D
			var collisionpolygon_transform: Transform2D = node.get_global_transform()
			var collisionpolygon: PackedVector2Array = collision_poly.polygon
			var new_collision_outline: PackedVector2Array = collisionpolygon_transform * collisionpolygon
			print("found collision obstacle %s" % [new_collision_outline])
			outlines.append(new_collision_outline)
	return outlines
