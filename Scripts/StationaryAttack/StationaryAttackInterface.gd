extends Node2D
class_name StationaryAttackInterface

var is_attack_highlight_on := false
var possible_attack_tiles: Array 

func get_attack_range() -> int:
	assert(false)
	return 0

func get_possible_target_tiles(grid_pos: Vector2) -> Array:
	assert(false)
	return []

func highlight_possible_target_tiles(target_tiles: Array, tilemap: CustomTileMap) -> void:
	tilemap.highlight_tiles(target_tiles)
	is_attack_highlight_on = true
	possible_attack_tiles = target_tiles

# Not meant to be called directly, only in conjunction with subclasses
# Bool indicates whether the attack took place or not
# For example if the target_grid_pos is not in one of the possible target tiles, false is returned
func perform_attack(target_grid_pos: Vector2, tilemap: CustomTileMap) -> bool:
	# Revert previous side effects
	tilemap.unhighlight_prev_tiles()
	is_attack_highlight_on = false
	# Attack not possible because the selected position, was not one of the
	# previously highlighted and valid positions for an attack
	if !(target_grid_pos in possible_attack_tiles):
		possible_attack_tiles = []
		return false
	possible_attack_tiles = []
	return true
