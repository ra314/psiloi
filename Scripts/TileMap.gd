extends TileMap
class_name CustomTileMap

const HIGHLIGHT_TILE_ENUM = 2
var highlight_tile_grid_pos_to_OG_value = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Reset previous highlights
func unhighlight_prev_tiles() -> void:
	for grid_pos in highlight_tile_grid_pos_to_OG_value.keys():
		var prev_tile_value = highlight_tile_grid_pos_to_OG_value[grid_pos]
		set_cellv(grid_pos, prev_tile_value)
	highlight_tile_grid_pos_to_OG_value.clear()

func highlight_tiles(grid_positions: Array) -> void:
	unhighlight_prev_tiles()
	# Perform and store new highlights
	for grid_position in grid_positions:
		highlight_tile_grid_pos_to_OG_value[grid_position] = get_cellv(grid_position)
		set_cellv(grid_position, HIGHLIGHT_TILE_ENUM)

func highlight_path(path: Array) -> void:
	yield(get_tree().create_timer(1), "timeout")
	for node in path:
		var og_value = get_cellv(node)
		set_cellv(node, 0)
		yield(get_tree().create_timer(0.2), "timeout")
		set_cellv(node, og_value)
