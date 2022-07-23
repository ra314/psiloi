extends Node2D

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
		LevelGenerator.apply_random_level($TileMap)

func highlight_tile(grid_position: Vector2) -> void:
	$TileMap.set_cell(grid_position.x, grid_position.y, 1)

func highlight_tiles(grid_positions: Array) -> void:
	for grid_position in grid_positions:
		highlight_tile(grid_position)


