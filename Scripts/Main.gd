extends Node2D

const HERO_SPAWN_POS := Vector2(0,6)
const ENEMY_SPAWN_POS := Vector2(3,3)
const EXIT_POS := Vector2(6,6)

onready var TurnManager = $TurnManager

# Called when the node enters the scene tree for the first time.
func _ready():
	create_valid_procedural_level()
	initialize_units()
	
	$Exit.position = $TileMap.map_to_world(EXIT_POS)

func initialize_units() -> void:
	$Units/Player.init($TileMap, HERO_SPAWN_POS, AUTO.TEAM.PLAYER)
	$Units/Player.can_move = true
	AUTO.players_set = HashSet.neww([$Units/Player])
	$Units/Enemy.init($TileMap, ENEMY_SPAWN_POS, AUTO.TEAM.ENEMY)
	AUTO.enemies_set = HashSet.neww([$Units/Enemy])
	
	AUTO.all_units = [$Units/Player, $Units/Enemy]

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
		if $TileMap.get_cellv(ENEMY_SPAWN_POS) in AUTO.BLOCKING_TILES:
			path = []
	print("num_tries " + str(num_tries))
	$TileMap.highlight_path(path)

var prev_selected_unit: Node2D = null
var is_selecting_attack := false
func _input(event):
	if event is InputEventMouseButton and event.is_action_released("click"):
		var grid_pos = $TileMap.world_to_map(event.position)
		var curr_selected_unit = AUTO.pos_to_unit_map.get(grid_pos, null)
		
		if is_selecting_attack:
			var attack_success = prev_selected_unit.stationary_attack(grid_pos)
			if attack_success:
				prev_selected_unit.action_done()
			is_selecting_attack = false
			prev_selected_unit = null
			return
		
		if curr_selected_unit and !curr_selected_unit.can_move:
			prev_selected_unit = null
			return
		
		if prev_selected_unit == null:
			prev_selected_unit = curr_selected_unit
		elif curr_selected_unit == prev_selected_unit:
			is_selecting_attack = true
			curr_selected_unit.stationary_attack(grid_pos)
		else:
			prev_selected_unit.move_with_bfs_to(grid_pos)
			prev_selected_unit.action_done()
			prev_selected_unit = null

