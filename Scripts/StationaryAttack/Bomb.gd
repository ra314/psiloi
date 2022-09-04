extends StationaryAttackInterface
const BOMBER_THROW_RANGE := 2

func get_attack_type():
	return AUTO.ATTACK.BOMB

func get_attack_range() -> int:
	return BOMBER_THROW_RANGE

func get_possible_target_tiles(grid_pos: Vector2) -> Array:
	return NAVIGATOR.get_grid_positions_within_distance(grid_pos, BOMBER_THROW_RANGE)

func perform_attack(target_grid_pos: Vector2, tilemap: CustomTileMap) -> bool:
	if not .perform_attack(target_grid_pos, tilemap):
		return false
	# Attack not possible because a unit is on the target tile
	if target_grid_pos in AUTO.pos_to_unit_map:
		return false
	# Attack not possible because the targettile is a blocking tile
	if tilemap.get_cellv(target_grid_pos) in AUTO.BLOCKING_TILES:
		return false
	add_bomb(target_grid_pos, tilemap)
	return true

var BOMB = load("res://Scenes/Bomb.tscn")
func add_bomb(target_grid_pos: Vector2, tilemap: CustomTileMap):
	var new_bomb = BOMB.instance()
	get_parent().Main.add_child(new_bomb)
	new_bomb.position = tilemap.map_to_world(target_grid_pos)
