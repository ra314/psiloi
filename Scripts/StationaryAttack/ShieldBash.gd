extends StationaryAttackInterface
class_name ShieldBashStationaryAttack
const SHIELD_ATTACK_RANGE := 1

func get_attack_type():
	return AUTO.ATTACK.SHIELDBASH

func get_attack_range() -> int:
	return SHIELD_ATTACK_RANGE

func get_possible_target_tiles(grid_pos: Vector2) -> Array:
	return NAVIGATOR.get_grid_positions_within_distance(grid_pos, SHIELD_ATTACK_RANGE)

func perform_attack(target_grid_pos: Vector2, tilemap: CustomTileMap, unit) -> bool:
	if not .perform_attack(target_grid_pos, tilemap, unit):
		return false
	# Attack not possible, since target isn't a unit
	if not (target_grid_pos in AUTO.pos_to_unit_map):
		return false
	# Perform bash
	var units_to_move_back = []
	var attack_dir = NAVIGATOR.get_direction_between_positions(unit.grid_pos, target_grid_pos)
	var curr_unit = AUTO.pos_to_unit_map.get(target_grid_pos, null)
	var curr_grid_pos = target_grid_pos
	# Get the units that should be moved backwards
	while curr_unit != null:
		units_to_move_back.append(curr_unit)
		curr_grid_pos = NAVIGATOR.call(attack_dir, curr_grid_pos)
		curr_unit = AUTO.pos_to_unit_map.get(curr_grid_pos, null)
	# Move the bashed units
	units_to_move_back.invert()
	for bashed_unit in units_to_move_back:
		var new_pos_for_unit = NAVIGATOR.call(attack_dir, bashed_unit.grid_pos)
		# Kill unit if pushed into a blocked tile
		if tilemap.get_cellv(new_pos_for_unit) in AUTO.BLOCKING_TILES:
			bashed_unit.die()
		else:
			bashed_unit.move_with_bfs_to(new_pos_for_unit)
	return true
