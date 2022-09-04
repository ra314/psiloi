extends Node2D
class_name Unit

var grid_pos: Vector2
var tilemap: TileMap
var curr_path: Array
const MOVEMENT_PERIOD := 0.2
var timer: Timer

var allowed_attack_enums: Dictionary
var team_enum = AUTO.TEAM.UNSET
var can_move := false
var Main
var stationary_attack_implementation: StationaryAttackInterface

func init(tilemap: TileMap, grid_pos: Vector2, team_enum, allowed_attack_enums: Dictionary) -> Unit:
	self.tilemap = tilemap
	self.team_enum = team_enum
	self.grid_pos = grid_pos
	self.allowed_attack_enums = allowed_attack_enums
	self.stationary_attack_implementation = \
		get_stationary_attack_implementation(allowed_attack_enums).new()
	
	position = tilemap.map_to_world(grid_pos)
	AUTO.pos_to_unit_map[grid_pos] = self
	Main = get_parent().get_parent()
	return self

# TODO: This doesn't work with multiple allowed stationary attacks
func get_stationary_attack_implementation(allowed_attack_enums):
	for attack_enum in allowed_attack_enums:
		if attack_enum in AUTO.attack_enum_to_class_map:
			return AUTO.attack_enum_to_class_map[attack_enum]
	assert(false)

# Return true if the movement is possible
func move_with_bfs_to(end_grid_pos: Vector2) -> bool:
	# If already moving, don't move again
	if curr_path != []:
		return false
		
	var path = NAVIGATOR.bfs_path(grid_pos, end_grid_pos, tilemap)
	if path == []:
		return false
	curr_path = path
	start_movement()
	return true

func start_movement():
	timer = Timer.new()
	timer.wait_time = MOVEMENT_PERIOD
	timer.stop()
	timer.connect("timeout", self, "move_along_path")
	add_child(timer)
	timer.start()

# Attacks if you move directly towards a unit and are now adjacent
func check_and_perform_stab_attack(prev_grid_pos: Vector2) -> void:
	if not (AUTO.ATTACK.STAB in allowed_attack_enums):
		return
	var target_grid_pos = NAVIGATOR.get_next_grid_pos_in_same_dir(prev_grid_pos, grid_pos)
	if !(target_grid_pos in AUTO.pos_to_unit_map):
		return
	var enemy: Unit = AUTO.pos_to_unit_map[target_grid_pos]
	enemy.die()

func move_unit_directly_to(new_grid_pos: Vector2) -> void:
	position = tilemap.map_to_world(new_grid_pos)
	AUTO.pos_to_unit_map.erase(grid_pos)
	grid_pos = new_grid_pos
	AUTO.pos_to_unit_map[grid_pos] = self

func move_along_path() -> void:
	var new_grid_pos: Vector2 = curr_path.pop_front()
	var prev_pos = grid_pos
	move_unit_directly_to(new_grid_pos)
	
	if curr_path == []:
		check_and_perform_stab_attack(prev_pos)
		timer.stop()
		return

func die():
	visible = false
	AUTO.pos_to_unit_map.erase(grid_pos)

func action_done():
	can_move = false
	if Main.TurnManager.check_ply_over(team_enum):
		Main.TurnManager.increment_ply_count(team_enum)

func stationary_attack(grid_pos) -> bool:
	if stationary_attack_implementation == null:
		return false
	if not (stationary_attack_implementation.get_attack_type() in allowed_attack_enums):
		return false
	if stationary_attack_implementation.is_attack_highlight_on:
		return stationary_attack_implementation.perform_attack(grid_pos, tilemap, self)
	var possible_target_tiles = \
		stationary_attack_implementation.get_possible_target_tiles(grid_pos)
	stationary_attack_implementation.\
		highlight_possible_target_tiles(possible_target_tiles, tilemap)
	return false

