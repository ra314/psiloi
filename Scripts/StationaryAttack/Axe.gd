extends StationaryAttackInterface
class_name AxeStationaryAttack
const AXE_ATTACK_RANGE := 1

func get_attack_type():
	return AUTO.ATTACK.AXE

func get_attack_range() -> int:
	return AXE_ATTACK_RANGE

func get_possible_target_tiles(grid_pos: Vector2) -> Array:
	return NAVIGATOR.get_grid_positions_within_distance(grid_pos, AXE_ATTACK_RANGE)

func perform_attack(target_grid_pos: Vector2, tilemap: CustomTileMap, unit) -> bool:
	if not .perform_attack(target_grid_pos, tilemap, unit):
		return false
	# Attack not possible, since target isn't a unit
	if not (target_grid_pos in AUTO.pos_to_unit_map):
		return false
	var left_and_right_poss = HashSet.intersection(\
					HashSet.neww(NAVIGATOR.get_surrounding_tiles(target_grid_pos)),\
					HashSet.neww(NAVIGATOR.get_surrounding_tiles(unit.grid_pos)))
	var kill_zone_poss = left_and_right_poss
	kill_zone_poss.append(target_grid_pos)
	for kill_zone_pos in kill_zone_poss:
		var target_unit = AUTO.pos_to_unit_map.get(kill_zone_pos, null)
		if target_unit:
			if unit.is_unit_on_other_team(target_unit):
				target_unit.die()
	return true
