class_name Navigator

const DIR_ALL = ["N", "S", "SE", "NW", "SW", "NE"]

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
