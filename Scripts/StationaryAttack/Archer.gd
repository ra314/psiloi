extends StationaryAttackInterface
class_name ArcherStationaryAttack
const ARCHER_ATTACK_RANGE := 5

func get_attack_type():
	return AUTO.ATTACK.ARCHER

func get_attack_range() -> int:
	return ARCHER_ATTACK_RANGE

func get_possible_target_tiles(grid_pos: Vector2) -> Array:
	return NAVIGATOR.get_radial_grid_positions_with_range(grid_pos, ARCHER_ATTACK_RANGE)

func perform_attack(target_grid_pos: Vector2, tilemap: CustomTileMap, unit) -> bool:
	if not .perform_attack(target_grid_pos, tilemap, unit):
		return false
	# Attack not possible, since target isn't a unit
	if not (target_grid_pos in AUTO.pos_to_unit_map):
		return false
	AUTO.pos_to_unit_map[target_grid_pos].die()
	return true
