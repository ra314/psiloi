extends Node2D

const HERO_SPAWN_POS := Vector2(0,6)
const ENEMY_SPAWN_POS := Vector2(3,3)
const EXIT_POS := Vector2(6,6)

# Called when the node enters the scene tree for the first time.
func _ready():
	create_valid_procedural_level()
	
	$Units/Player.init($TileMap, HERO_SPAWN_POS)
	$Units/Enemy.init($TileMap, ENEMY_SPAWN_POS)
	$Exit.position = $TileMap.map_to_world(EXIT_POS)

func create_valid_procedural_level() -> void:
	var num_tries = 0
	assert(LevelGenerator.LEVEL_SIZE.x > EXIT_POS.x)
	assert(LevelGenerator.LEVEL_SIZE.y > EXIT_POS.y)
	LevelGenerator.apply_random_level_to_tilemap($TileMap)
	var path = NAVIGATOR.bfs_path(HERO_SPAWN_POS, EXIT_POS, $TileMap)
	while(path == []):
		LevelGenerator.apply_random_level_to_tilemap($TileMap)
		path = NAVIGATOR.bfs_path(HERO_SPAWN_POS, EXIT_POS, $TileMap)
		num_tries += 1
	print("num_tries " + str(num_tries))
	$TileMap.highlight_path(path)

var prev_selected_unit: Node2D = null
var is_selecting_attack := false
func _input(event):
	if event is InputEventMouseButton and event.is_action_released("click"):
		var grid_pos = $TileMap.world_to_map(event.position)
		var curr_selected_unit = AUTO.pos_to_unit_map.get(grid_pos, null)
		
		if is_selecting_attack:
			prev_selected_unit.stationary_attack(grid_pos)
			is_selecting_attack = false
			prev_selected_unit = null
			return
		
		if prev_selected_unit == null:
			prev_selected_unit = curr_selected_unit
		elif curr_selected_unit == prev_selected_unit:
			is_selecting_attack = !curr_selected_unit.stationary_attack()
		else:
			prev_selected_unit.move_with_bfs_to(grid_pos)
			prev_selected_unit = null



