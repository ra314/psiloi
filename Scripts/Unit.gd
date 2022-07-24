extends Node2D
class_name Unit

var grid_pos: Vector2
var tilemap: TileMap
var curr_path: Array
const MOVEMENT_PERIOD := 0.2
var timer: Timer


func init(tilemap: TileMap) -> Unit:
	self.tilemap = tilemap
	self.grid_pos = tilemap.world_to_map(position)
	
	timer = Timer.new()
	timer.wait_time = MOVEMENT_PERIOD
	timer.stop()
	timer.connect("timeout", self, "move_along_path")
	add_child(timer)
	
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
	timer.start()

func check_and_perform_stab_attack(prev_grid_pos: Vector2) -> void:
	var target_grid_pos = NAVIGATOR.get_next_grid_pos_in_same_dir(prev_grid_pos, grid_pos)
	if !(target_grid_pos in CACHE.pos_to_unit_map):
		return
	var enemy: Unit = CACHE.pos_to_unit_map[target_grid_pos]
	enemy.die()

func move_along_path() -> void:
	var node: Vector2 = curr_path.pop_front()
	position = tilemap.map_to_world(node)
	CACHE.pos_to_unit_map.erase(grid_pos)
	var prev_pos = grid_pos
	grid_pos = node
	CACHE.pos_to_unit_map[grid_pos] = self
	
	if curr_path == []:
		check_and_perform_stab_attack(prev_pos)
		timer.stop()
		return

func die():
	visible = false
	CACHE.pos_to_unit_map[grid_pos] = null

static func cache_unit_locations(units: Array, tilemap: TileMap) -> void:
	for unit in units:
		var grid_pos = tilemap.world_to_map(unit.position)
		CACHE.pos_to_unit_map[grid_pos] = unit

