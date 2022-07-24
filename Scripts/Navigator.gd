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
