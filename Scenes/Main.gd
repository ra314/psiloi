extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event) -> void:
	# A simple code to show how to you can manipulate hexes using the mouse.
	#var mouse_offset: Vector2 = Vector2(-11,-6) 
	if event.is_action_released("ui_select"):
		var grid_pos: Vector2 = $TileMap.world_to_map(get_global_mouse_position())
		print(get_surrounding_tiles(grid_pos))
		highlight_tiles(get_surrounding_tiles(grid_pos))

func highlight_tile(grid_position: Vector2) -> void:
	$TileMap.set_cell(grid_position.x, grid_position.y, 1)

func highlight_tiles(grid_positions: Array) -> void:
	for grid_position in grid_positions:
		highlight_tile(grid_position)

func get_surrounding_tiles(grid_pos: Vector2) -> Array:
	var grid_positions = []
	for dir in Directions.DIR_ALL:
		grid_positions.append(call(dir, grid_pos))
	return grid_positions
