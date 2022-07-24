extends Node2D

const HERO_SPAWN_POS := Vector2(0,7)
const EXIT_POS := Vector2(19,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	create_valid_procedural_level()
	
	$Units/Player.position = $TileMap.map_to_world(HERO_SPAWN_POS)
	
	for child in $Units.get_children():
		child.init($TileMap)
	Unit.cache_unit_locations($Units.get_children(), $TileMap)

func create_valid_procedural_level() -> void:
	var num_tries = 0
	LevelGenerator.apply_random_level_to_tilemap($TileMap)
	var path = NAVIGATOR.bfs_path(HERO_SPAWN_POS, EXIT_POS, $TileMap)
	while(path == []):
		LevelGenerator.apply_random_level_to_tilemap($TileMap)
		path = NAVIGATOR.bfs_path(HERO_SPAWN_POS, EXIT_POS, $TileMap)
		num_tries += 1
	print("num_tries " + str(num_tries))
	$TileMap.highlight_path(path)

var prev_selected_unit: Node2D = null

func _input(event):
	if event is InputEventMouseButton and event.is_action_released("click"):
		var grid_pos = $TileMap.world_to_map(event.position)
		var curr_selected_unit = CACHE.pos_to_unit_map.get(grid_pos, null)
		if prev_selected_unit == null:
			prev_selected_unit = curr_selected_unit
		else:
			prev_selected_unit.move_with_bfs_to(grid_pos)
			prev_selected_unit = null



