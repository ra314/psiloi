### NAVIGATOR
extends Node

const DIR_ALL = ["N", "S", "SE", "NW", "SW", "NE"]
const BLOCKING_TILES = {0:true, -1:true}

func N(grid_pos: Vector2) -> Vector2:
	return grid_pos + Vector2(0,-1)

func S(grid_pos: Vector2) -> Vector2:
	return grid_pos + Vector2(0,1)

func SE(grid_pos: Vector2) -> Vector2:
	if int(grid_pos.x)%2 == 0:
		return grid_pos + Vector2(1,0)
	return grid_pos + Vector2(1,1)

func NW(grid_pos: Vector2) -> Vector2:
	if int(grid_pos.x)%2 == 0:
		return grid_pos + Vector2(-1,-1)
	return grid_pos + Vector2(-1,0)

func SW(grid_pos: Vector2) -> Vector2:
	if int(grid_pos.x)%2 == 0:
		return grid_pos + Vector2(-1,0)
	return grid_pos + Vector2(-1,1)

func NE(grid_pos: Vector2) -> Vector2:
	if int(grid_pos.x)%2 == 0:
		return grid_pos + Vector2(1,-1)
	return grid_pos + Vector2(1,0)

# Returns "" if there is no straight line between the two positions
# Also returns "" if start and end are the same
const MAX_LINEAR_SEARCH_DISTANCE := 100
func get_direction_between_positions(start_grid_pos: Vector2, end_grid_pos: Vector2) -> String:
	if start_grid_pos == end_grid_pos:
		return ""
	var dir_to_last_pos_map = {}
	for dir in DIR_ALL:
		dir_to_last_pos_map[dir] = start_grid_pos
	for i in range(MAX_LINEAR_SEARCH_DISTANCE):
		for dir in DIR_ALL:
			dir_to_last_pos_map[dir] = call(dir, dir_to_last_pos_map[dir])
			if dir_to_last_pos_map[dir] == end_grid_pos:
				return dir
	return ""

# Does not include the starting grid position
func get_grid_positions_along_line(start_grid_pos: Vector2, distance: int, direction: String) -> Array:
	assert(direction in DIR_ALL)
	var grid_positions = []
	var curr_pos = start_grid_pos
	for i in range(distance):
		curr_pos = call(direction, curr_pos)
		grid_positions.append(curr_pos)
	return grid_positions

func get_grid_positions_within_distance(grid_pos: Vector2, distance: int) -> Array:
	var positions = {}
	positions[grid_pos] = true
	
	# This is a bit slow, but should be good enough
	for i in range(distance):
		for pos in positions.keys():
			for adjacent_pos in get_surrounding_tiles(pos):
				positions[adjacent_pos] = true
	return positions.keys()

func get_radial_grid_positions_with_range(grid_pos: Vector2, radius: int) -> Array:
	var grid_positions = []
	for dir in DIR_ALL:
		var curr_pos = grid_pos
		for i in range(radius):
			curr_pos = call(dir, curr_pos)
			grid_positions.append(curr_pos)
	return grid_positions

func get_next_grid_pos_in_same_dir(prev_grid_pos: Vector2, curr_grid_pos: Vector2) -> Vector2:
	var tiles_to_dir_map = get_surrounding_tiles_to_dir_map(prev_grid_pos)
	var last_movement_dir = tiles_to_dir_map[curr_grid_pos]
	var next_pos_in_same_dir = call(last_movement_dir, curr_grid_pos)
	return next_pos_in_same_dir

func get_surrounding_tiles_to_dir_map(grid_pos: Vector2) -> Dictionary:
	var grid_positions = {}
	for dir in DIR_ALL:
		grid_positions[call(dir, grid_pos)] = dir
	return grid_positions

func get_surrounding_tiles(grid_pos: Vector2) -> Array:
	var grid_positions = []
	for dir in DIR_ALL:
		grid_positions.append(call(dir, grid_pos))
	return grid_positions

func backtrace_path(node_to_prev_node_map: Dictionary, node: Vector2, start_grid_pos: Vector2) -> Array:
	var path = []
	while node != start_grid_pos:
		path.append(node)
		node = node_to_prev_node_map[node]
	path.append(node)
	path.invert()
	return path

func bfs_path(start_grid_pos: Vector2, end_grid_pos: Vector2, tilemap: TileMap) -> Array:
	if tilemap.get_cellv(start_grid_pos) in BLOCKING_TILES:
		return []
	
	var bfs_queue = []
	var node_to_prev_node_map = {}
	bfs_queue.append(start_grid_pos)
	
	# Find path with BFS
	var node: Vector2
	while len(bfs_queue) != 0:
		node = bfs_queue.pop_front()
		if node == end_grid_pos:
			return backtrace_path(node_to_prev_node_map, node, start_grid_pos)
		for surrounding_node in get_surrounding_tiles(node):
			if !(tilemap.get_cellv(surrounding_node) in BLOCKING_TILES):
				if !(surrounding_node in node_to_prev_node_map):
					node_to_prev_node_map[surrounding_node] = node
					bfs_queue.append(surrounding_node)
	return []
