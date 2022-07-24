extends TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func highlight_tile(grid_position: Vector2) -> void:
	.set_cell(grid_position.x, grid_position.y, 1)

func highlight_tiles(grid_positions: Array) -> void:
	for grid_position in grid_positions:
		highlight_tile(grid_position)

func highlight_path(path: Array) -> void:
	yield(get_tree().create_timer(1), "timeout")
	for node in path:
		var og_value = get_cellv(node)
		set_cellv(node, 0)
		yield(get_tree().create_timer(0.2), "timeout")
		set_cellv(node, og_value)
