extends Node2D

const HERO_SPAWN_POS := Vector2(0,7)
const EXIT_POS := Vector2(19,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event) -> void:
	# A simple code to show how to you can manipulate hexes using the mouse.
	#var mouse_offset: Vector2 = Vector2(-11,-6) 
	if event.is_action_released("ui_select"):
		var grid_pos: Vector2 = $TileMap.world_to_map(get_global_mouse_position())
		print(Navigator.get_surrounding_tiles(grid_pos))
		highlight_tiles(Navigator.get_surrounding_tiles(grid_pos))
		
		var num_tries = 0
		LevelGenerator.apply_random_level($TileMap)
		var path = Navigator.bfs_path(HERO_SPAWN_POS, EXIT_POS, $TileMap)
		while(path == []):
			LevelGenerator.apply_random_level($TileMap)
			path = Navigator.bfs_path(HERO_SPAWN_POS, EXIT_POS, $TileMap)
			num_tries += 1
		print("num_tries " + str(num_tries))
		
		highlight_path(path, $TileMap)

func highlight_tile(grid_position: Vector2) -> void:
	$TileMap.set_cell(grid_position.x, grid_position.y, 1)

func highlight_tiles(grid_positions: Array) -> void:
	for grid_position in grid_positions:
		highlight_tile(grid_position)

func highlight_path(path: Array, tilemap: TileMap) -> void:
	for node in path:
		var og_value = tilemap.get_cellv(node)
		tilemap.set_cellv(node, 0)
		yield(get_tree().create_timer(0.2), "timeout")
		tilemap.set_cellv(node, og_value)
