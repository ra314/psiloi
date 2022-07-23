class_name Directions

const DIR_ALL = ["N", "S", "SE", "NW", "SW", "NE"]

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
