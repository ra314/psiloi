extends Node2D

const HERO_SPAWN_POS := Vector2(0,7)
const EXIT_POS := Vector2(19,1)
var pos_to_unit_map: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	create_valid_procedural_level()
	$Units/Player.position = $TileMap.map_to_world(HERO_SPAWN_POS)
	pos_to_unit_map = cache_unit_locations()

func create_valid_procedural_level() -> void:
	var num_tries = 0
	LevelGenerator.apply_random_level($TileMap)
	var path = Navigator.bfs_path(HERO_SPAWN_POS, EXIT_POS, $TileMap)
	while(path == []):
		LevelGenerator.apply_random_level($TileMap)
		path = Navigator.bfs_path(HERO_SPAWN_POS, EXIT_POS, $TileMap)
		num_tries += 1
	print("num_tries " + str(num_tries))
	highlight_path(path, $TileMap)

func cache_unit_locations() -> Dictionary:
	var pos_to_unit_map: Dictionary = {}
	for child in $Units.get_children():
		var grid_pos = $TileMap.world_to_map(child.position)
		pos_to_unit_map[grid_pos] = child
	return pos_to_unit_map

var selected_unit: Node2D = null

func _input(event):
	if event is InputEventMouseButton and event.is_action_released("click"):
		var grid_pos = $TileMap.world_to_map(event.position)
		var node = pos_to_unit_map.get(grid_pos, null)
		if selected_unit == null:
			if node != null:
				selected_unit = node
		else:
			var selected_unit_grid_pos = $TileMap.world_to_map(selected_unit.position)
			var path = Navigator.bfs_path(selected_unit_grid_pos, grid_pos, $TileMap)
			animate_along_path(path, selected_unit)
			if path != []:
				pos_to_unit_map[selected_unit_grid_pos] = null
				pos_to_unit_map[grid_pos] = selected_unit
			selected_unit = null
		print(selected_unit)

func animate_along_path(path: Array, unit: Node2D) -> void:
	for node in path:
		unit.position = $TileMap.map_to_world(node)
		yield(get_tree().create_timer(0.2), "timeout")

func highlight_tile(grid_position: Vector2) -> void:
	$TileMap.set_cell(grid_position.x, grid_position.y, 1)

func highlight_tiles(grid_positions: Array) -> void:
	for grid_position in grid_positions:
		highlight_tile(grid_position)

func highlight_path(path: Array, tilemap: TileMap) -> void:
	yield(get_tree().create_timer(1), "timeout")
	for node in path:
		var og_value = tilemap.get_cellv(node)
		tilemap.set_cellv(node, 0)
		yield(get_tree().create_timer(0.2), "timeout")
		tilemap.set_cellv(node, og_value)
