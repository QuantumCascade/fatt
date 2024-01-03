class_name Map
extends Node2D

## Maximum squared distance from mouse cursor to tower lane to display a tower placeholder
@export var max_sq_dist_to_tower_point: float = 625

# Emitted when mouse cursor close to a tower lane
signal pointed_tower_lane_pos

# Filled on startup from TowerLines statically defined on map
var tower_lanes: Array[Curve2D] = []
# This is to remember original navigation region
var orig_nav_outlines: Array[PackedVector2Array]

@onready var nav_region: NavigationRegion2D = %NavigationRegion
@onready var terrain_tile_map: TileMap = %TerrainTileMap

func _ready():
	init_tower_lanes()
	
	# write original vertices to use during reprocessing
	orig_nav_outlines = nav_region.navigation_polygon.outlines
	# add mountains as navigation obstacles
	enrich_nav_region(find_terrain_obstacles())


func init_tower_lanes():
	for tower_line in %TowerLines.get_children() as Array[Line2D]:
		var curve: Curve2D = Curve2D.new()
		for point in tower_line.points:
			curve.add_point(point)
		tower_lanes.append(curve)


func _input(_event: InputEvent):
	check_tower_lanes()


# emits the nearest tower lane coords to the current mouse cursor pos
func check_tower_lanes():
	var mouse_pos = get_global_mouse_position()
	var closest_point: Vector2 = Vector2.ZERO
	var distance_to_closest_point: float = 999999.0
	for tower_line in tower_lanes:
		var p1 = tower_line.get_closest_point(mouse_pos)
		var d1 = mouse_pos.distance_squared_to(p1)
		if d1 < distance_to_closest_point:
			distance_to_closest_point = d1
			closest_point = p1
	if max_sq_dist_to_tower_point < distance_to_closest_point:
		closest_point = Vector2.ZERO
	pointed_tower_lane_pos.emit(closest_point)


# Adds to (or substracts from) the nav region given list of polygons (outlines)
func enrich_nav_region(outlines: Array[PackedVector2Array]):
	# Mesh is a set of polygons
	var new_navigation_mesh: NavigationPolygon = NavigationPolygon.new()
	new_navigation_mesh.cell_size = nav_region.navigation_polygon.cell_size
	new_navigation_mesh.agent_radius = nav_region.navigation_polygon.agent_radius
	
	for outline in orig_nav_outlines:
		new_navigation_mesh.add_outline(outline)
	
	for outline in outlines:
		new_navigation_mesh.add_outline(outline)
	
	var callback: Callable = func():
		_set_baked_nav_mesh(new_navigation_mesh)
	
	nav_region.navigation_polygon = new_navigation_mesh
	NavigationServer2D.bake_from_source_geometry_data(new_navigation_mesh, \
		NavigationMeshSourceGeometryData2D.new(), callback)


# This is to handle async callback after baking (in a separate thread usually)
func _set_baked_nav_mesh(new_poly: NavigationPolygon):
	print("baked mesh with outlines n=%s" % [new_poly.get_outline_count()])
	NavigationServer2D.region_set_navigation_polygon(nav_region.get_region_rid(), new_poly)
	nav_region.navigation_polygon = new_poly # This is messy in Godot 4.2, but works


# Scans tree to find new collision obstacles and then merges findings to the navigation region
func reprocess_navigation_region(root_node: Node):
	var collision_outlines: Array[PackedVector2Array] = find_collisionshapes(root_node)
	var terrain_outlines: Array[PackedVector2Array] = find_terrain_obstacles()
	collision_outlines.append_array(terrain_outlines)
	enrich_nav_region(collision_outlines)


# Searches for collision polygons from the given node recursively
func find_collisionshapes(root_node: Node, outlines: Array[PackedVector2Array] = []) -> Array[PackedVector2Array]:
	#print("check obstacles in %s" % root_node)
	for node in root_node.get_children():
		if node is Node and node.get_child_count() > 0:
			find_collisionshapes(node, outlines)
		if not (node is CollisionPolygon2D):
			continue
		if node.get_parent() is Area2D:
			continue
		# TODO: check if collision layer is what we need (currently we use 1)
		var collision_poly: CollisionPolygon2D = node as CollisionPolygon2D
		var collisionpolygon_transform: Transform2D = node.get_global_transform()
		var collisionpolygon: PackedVector2Array = collision_poly.polygon
		var new_collision_outline: PackedVector2Array = collisionpolygon_transform * collisionpolygon
		#print("found collision obstacle %s" % [new_collision_outline])
		outlines.append(new_collision_outline)
	return outlines


# Returns outlines from the TileMap (there are mountains with collision polygons)
func find_terrain_obstacles() -> Array[PackedVector2Array]:
	var terrain_outlines: Array[PackedVector2Array] = []
	for cell: Vector2i in terrain_tile_map.get_used_cells(0):
		var tile_data: TileData = terrain_tile_map.get_cell_tile_data(0, cell)
		if tile_data and tile_data.get_collision_polygons_count(0) > 0:
			var tile_global_pos: Vector2 = terrain_tile_map.to_global(terrain_tile_map.map_to_local(cell))
			var tile_collision_poly: PackedVector2Array = tile_data.get_collision_polygon_points(0, 0)
			var global_tile_poly: PackedVector2Array = PackedVector2Array()
			for vertex in tile_collision_poly:
				var as_glob: Vector2 = vertex + tile_global_pos
				global_tile_poly.append(as_glob)
			terrain_outlines.append(global_tile_poly)
	return terrain_outlines
