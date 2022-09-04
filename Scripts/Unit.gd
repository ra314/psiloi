extends Node2D
class_name Unit

var grid_pos: Vector2
var tilemap: TileMap
var curr_path: Array
const MOVEMENT_PERIOD := 0.2
var timer: Timer
var is_enemy: bool
var move_over := false
var Main

func init(tilemap: TileMap, grid_pos: Vector2, is_enemy: bool) -> Unit:
	self.tilemap = tilemap
	self.is_enemy = is_enemy
	self.grid_pos = grid_pos
	position = tilemap.map_to_world(grid_pos)
	AUTO.pos_to_unit_map[grid_pos] = self
	Main = get_parent()
	return self

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

func check_and_perform_stab_attack(prev_grid_pos: Vector2) -> void:
	var target_grid_pos = NAVIGATOR.get_next_grid_pos_in_same_dir(prev_grid_pos, grid_pos)
	if !(target_grid_pos in AUTO.pos_to_unit_map):
		return
	var enemy: Unit = AUTO.pos_to_unit_map[target_grid_pos]
	enemy.die()

func move_along_path() -> void:
	var node: Vector2 = curr_path.pop_front()
	position = tilemap.map_to_world(node)
	AUTO.pos_to_unit_map.erase(grid_pos)
	var prev_pos = grid_pos
	grid_pos = node
	AUTO.pos_to_unit_map[grid_pos] = self
	
	if curr_path == []:
		check_and_perform_stab_attack(prev_pos)
		timer.stop()
		return

func die():
	visible = false
	AUTO.pos_to_unit_map.erase(grid_pos)

func action_done():
	move_over = true

func stationary_attack(grid_pos) -> void:
	if $StationaryAttackInterface.is_attack_highlight_on:
		$StationaryAttackInterface.perform_attack(grid_pos, tilemap)
		return
	var possible_target_tiles = $StationaryAttackInterface.get_possible_target_tiles(grid_pos)
	$StationaryAttackInterface.highlight_possible_target_tiles(possible_target_tiles, tilemap)
	return


