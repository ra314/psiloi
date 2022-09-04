extends StationaryAttackInterface
class_name WizardStationaryAttack
const WIZARD_BLAST_RANGE := 6

func get_attack_type():
	return AUTO.ATTACK.WIZARD

func get_attack_range() -> int:
	return WIZARD_BLAST_RANGE

var curr_grid_pos
func get_possible_target_tiles(grid_pos: Vector2) -> Array:
	curr_grid_pos = grid_pos
	return NAVIGATOR.get_radial_grid_positions_with_range(grid_pos, WIZARD_BLAST_RANGE)

func perform_attack(target_grid_pos: Vector2, tilemap: CustomTileMap, unit) -> bool:
	if not .perform_attack(target_grid_pos, tilemap, unit):
		return false
	var attack_direction = NAVIGATOR.get_direction_between_positions(curr_grid_pos, target_grid_pos)
	curr_grid_pos = null
	# No attack can be performed because the selected point is not in a straight line.
	# Should not be possible since a previous check checks if the selected position
	# is part of the previously highlighted positions
	if attack_direction == "":
		assert(false)
		return false
	for attacked_grid_pos in \
		NAVIGATOR.get_grid_positions_along_line(curr_grid_pos, WIZARD_BLAST_RANGE, attack_direction):
		if attacked_grid_pos in AUTO.pos_to_unit_map:
			AUTO.pos_to_unit_map[attacked_grid_pos].die()
	return true
