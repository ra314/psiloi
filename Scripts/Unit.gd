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
		
	var path = Navigator.bfs_path(grid_pos, end_grid_pos, tilemap)
	curr_path = path
	start_movement()
	
	return curr_path != []

func start_movement():
	timer.start()

func move_along_path() -> void:
	if curr_path == []:
		timer.stop()
		return
	
	var node: Vector2 = curr_path.pop_front()
	position = tilemap.map_to_world(node)
	CACHE.pos_to_unit_map.erase(grid_pos)
	grid_pos = node
	CACHE.pos_to_unit_map[grid_pos] = self

static func cache_unit_locations(units: Array, tilemap: TileMap) -> void:
	for unit in units:
		var grid_pos = tilemap.world_to_map(unit.position)
		CACHE.pos_to_unit_map[grid_pos] = unit

