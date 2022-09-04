extends StationaryAttackInterface
class_name LanceStationaryAttack
const LANCE_JUMP_RANGE := 2

func get_attack_type():
	return AUTO.ATTACK.LANCE

func get_attack_range() -> int:
	return LANCE_JUMP_RANGE

func get_possible_target_tiles(grid_pos: Vector2) -> Array:
	return NAVIGATOR.get_grid_positions_within_distance(grid_pos, LANCE_JUMP_RANGE)

func perform_attack(target_grid_pos: Vector2, tilemap: CustomTileMap, unit) -> bool:
	if not .perform_attack(target_grid_pos, tilemap, unit):
		return false
	# Attack not possible because a unit is on the target tile
	if target_grid_pos in AUTO.pos_to_unit_map:
		return false
	# Attack not possible because the targettile is a blocking tile
	if tilemap.get_cellv(target_grid_pos) in AUTO.BLOCKING_TILES:
		return false
	unit.move_unit_directly_to(target_grid_pos)
	return true
