extends StationaryAttackInterface
class_name ArcherStationaryAttack
const MAX_ARCHER_ATTACK_RANGE := 5
const MIN_ARCHER_ATTACK_RANGE := 1

func get_attack_type():
	return AUTO.ATTACK.ARCHER

func get_attack_range() -> int:
	return MAX_ARCHER_ATTACK_RANGE

func get_possible_target_tiles(grid_pos: Vector2) -> Array:
	return NAVIGATOR.get_radial_grid_positions_with_range(grid_pos, \
		MIN_ARCHER_ATTACK_RANGE, MAX_ARCHER_ATTACK_RANGE)

func perform_attack(target_grid_pos: Vector2, tilemap: CustomTileMap, unit) -> bool:
	if not .perform_attack(target_grid_pos, tilemap, unit):
		return false
	# Find tiles along the line of attack
	var attack_dir = NAVIGATOR.get_direction_between_positions(unit.grid_pos, target_grid_pos)
	var attackable_grid_poss = NAVIGATOR.get_grid_positions_along_line(unit.grid_pos, MAX_ARCHER_ATTACK_RANGE, attack_dir)
	for i in range(len(attackable_grid_poss)):
		var grid_pos = attackable_grid_poss[i]
		if i < MIN_ARCHER_ATTACK_RANGE:
			continue
		var target_unit = AUTO.pos_to_unit_map.get(grid_pos, null)
		if target_unit:
			if unit.is_unit_on_other_team(target_unit):
				target_unit.die()
				return true
			else:
				return false
	return false
