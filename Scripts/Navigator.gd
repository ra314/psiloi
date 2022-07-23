class_name Navigator

const DIR_ALL = ["N", "S", "SE", "NW", "SW", "NE"]
const BLOCKING_TILES = {0:true, -1:true}

static func N(grid_pos: Vector2) -> Vector2:
	return grid_pos + Vector2(0,-1)

static func S(grid_pos: Vector2) -> Vector2:
	return grid_pos + Vector2(0,1)

static func SE(grid_pos: Vector2) -> Vector2:
	if int(grid_pos.x)%2 == 0:
		return grid_pos + Vector2(1,0)
	return grid_pos + Vector2(1,1)

static func NW(grid_pos: Vector2) -> Vector2:
	if int(grid_pos.x)%2 == 0:
		return grid_pos + Vector2(-1,-1)
	return grid_pos + Vector2(-1,0)

static func SW(grid_pos: Vector2) -> Vector2:
	if int(grid_pos.x)%2 == 0:
		return grid_pos + Vector2(-1,0)
	return grid_pos + Vector2(-1,1)

static func NE(grid_pos: Vector2) -> Vector2:
	if int(grid_pos.x)%2 == 0:
		return grid_pos + Vector2(1,-1)
	return grid_pos + Vector2(1,0)

static func get_surrounding_tiles(grid_pos: Vector2) -> Array:
	var grid_positions = []
	grid_positions.append(N(grid_pos))
	grid_positions.append(S(grid_pos))
	grid_positions.append(NE(grid_pos))
	grid_positions.append(NW(grid_pos))
	grid_positions.append(SE(grid_pos))
	grid_positions.append(SW(grid_pos))
	return grid_positions

static func backtrace_path(node_to_prev_node_map: Dictionary, node: Vector2, start_grid_pos: Vector2) -> Array:
	var path = []
	while node != start_grid_pos:
		path.append(node)
		node = node_to_prev_node_map[node]
	path.append(node)
	path.invert()
	return path

static func bfs_path(start_grid_pos: Vector2, end_grid_pos: Vector2, tilemap: TileMap) -> Array:
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
