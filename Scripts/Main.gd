extends Node2D
 
const ENEMY_SPAWN_POS1 := Vector2(3,3)
const ENEMY_SPAWN_POS2 := Vector2(3,4)
const ENTRY_POS := Vector2(0,6)
const EXIT_POS := Vector2(6,6)

var PLAYER = load("res://Scenes/Player.tscn")
var ENEMY = load("res://Scenes/Enemy.tscn")
var LADDER = load("res://Scenes/Level Components/Ladder.tscn")

onready var TurnManager = $TurnManager

# Called when the node enters the scene tree for the first time.
func _ready():
	#create_valid_procedural_level()
	#static_initialize_units()
	
	create_valid_dynamic_procedural_level()
	yield(dynamic_initialize_units(), "completed")
	
	AUTO.players_set.keys()[0].can_move = true
	connect("mouse_click", self, "process_input")

func dynamic_initialize_units() -> void:
	var label = Label.new()
	add_child(label)
	
	$PowerupSelector.visible = true
	$PowerupSelector.init(AUTO.ATTACK.keys())
	
	var entry = LADDER.instance()
	entry.position = $TileMap.map_to_world(get_random_non_blocking_tile())
	add_child(entry)
	var exit = LADDER.instance()
	exit.position = $TileMap.map_to_world(get_random_non_blocking_tile())
	exit.modulate = Color(0,0,0,1)
	add_child(exit)
	
	label.text = "Click anywhere to place the Hero."
	var grid_pos = yield(self, "mouse_click")[0]
	var player = AUTO.add_childv2($Units, PLAYER.instance()).init($TileMap, grid_pos, \
		AUTO.TEAM.PLAYER, HashSet.neww($PowerupSelector.get_selected_powerups()))
	
	label.text = "Click anywhere to place the enemies. Click on a blocking tile to finish."
	grid_pos = yield(self, "mouse_click")[0]
	var enemies = []
	while !($TileMap.get_cellv(grid_pos) in AUTO.BLOCKING_TILES):
		enemies.append(AUTO.add_childv2($Units, ENEMY.instance()).init($TileMap, grid_pos, \
		AUTO.TEAM.ENEMY, HashSet.neww($PowerupSelector.get_selected_powerups())))
		grid_pos = yield(self, "mouse_click")[0]
	
	AUTO.players_set = HashSet.neww([player])
	AUTO.enemies_set = HashSet.neww(enemies)
	AUTO.all_units = enemies + [player]
	
	label.queue_free()
	$PowerupSelector.visible = false

func get_random_non_blocking_tile() -> Vector2:
	var SEARCH_LIMIT = 1000
	var count = 0
	var curr_pos = Vector2(-1,-1)
	while $TileMap.get_cellv(curr_pos) in AUTO.BLOCKING_TILES:
		curr_pos = AUTO.random_int_vector(LevelGenerator.LEVEL_SIZE.x, LevelGenerator.LEVEL_SIZE.y)
		count += 1
		assert(count < SEARCH_LIMIT)
	return curr_pos

func static_initialize_units() -> void:
	var player = AUTO.add_childv2($Units, PLAYER.instance()).init($TileMap, ENTRY_POS, \
		AUTO.TEAM.PLAYER, HashSet.neww([AUTO.ATTACK.STAB, AUTO.ATTACK.ARCHER]))
	var enemy1 = AUTO.add_childv2($Units, ENEMY.instance()).init($TileMap, ENEMY_SPAWN_POS1, \
		AUTO.TEAM.ENEMY, HashSet.neww([AUTO.ATTACK.SLASH]))
	var enemy2 = AUTO.add_childv2($Units, ENEMY.instance()).init($TileMap, ENEMY_SPAWN_POS2, \
		AUTO.TEAM.ENEMY, HashSet.neww([AUTO.ATTACK.SLASH]))
	AUTO.players_set = HashSet.neww([player])
	AUTO.enemies_set = HashSet.neww([enemy1, enemy2])
	AUTO.all_units = [player, enemy1, enemy2]
	LADDER.instance().position = $TileMap.map_to_world(EXIT_POS)

const LEVEL_RETRY_LIMIT = 100

func create_valid_dynamic_procedural_level() -> void:
	var num_tries = 0
	while(true):
		var level_array = LevelGenerator.generate_level_through_ablation()
		LevelGenerator.apply_random_level_to_tilemap(level_array, $TileMap)
		if validate_level_has_no_islands($TileMap):
			break
		num_tries += 1
		if num_tries > LEVEL_RETRY_LIMIT:
			break
		#assert(num_tries < LEVEL_RETRY_LIMIT)
	print("num_tries to generate level:" + str(num_tries))

func validate_level_has_no_islands(tilemap: CustomTileMap) -> bool:
	var land_tiles_set = HashSet.neww([])
	for x in range(LevelGenerator.LEVEL_SIZE.x):
		for y in range(LevelGenerator.LEVEL_SIZE.y):
			var pos = Vector2(x,y)
			if !($TileMap.get_cellv(pos) in AUTO.BLOCKING_TILES):
				HashSet.add(land_tiles_set, pos)
	assert(len(land_tiles_set)!=0)
	var bfs_explored_tiles_set = HashSet.neww([])
	var curr_len_explored = 0
	while curr_len_explored != len(bfs_explored_tiles_set):
		for tile in bfs_explored_tiles_set:
			for adjacent_tile in NAVIGATOR.get_surrounding_tiles(tile):
				HashSet.add(bfs_explored_tiles_set, adjacent_tile)
	var intersection = HashSet.intersection(land_tiles_set, bfs_explored_tiles_set)
	return len(intersection) == len(land_tiles_set)

func create_valid_static_procedural_level() -> void:
	var num_tries = 0
	var level_array = LevelGenerator.generate_level()
	LevelGenerator.apply_random_level_to_tilemap(level_array, $TileMap)
	var path = NAVIGATOR.bfs_path(ENTRY_POS, EXIT_POS, $TileMap)
	while(path == []):
		level_array = LevelGenerator.generate_level()
		LevelGenerator.apply_random_level_to_tilemap(level_array, $TileMap)
		path = NAVIGATOR.bfs_path(ENTRY_POS, EXIT_POS, $TileMap)
		if $TileMap.get_cellv(ENEMY_SPAWN_POS1) in AUTO.BLOCKING_TILES:
			path = []
		if $TileMap.get_cellv(ENEMY_SPAWN_POS2) in AUTO.BLOCKING_TILES:
			path = []
		num_tries += 1
		assert(num_tries < LEVEL_RETRY_LIMIT)
	print("num_tries to generate level:" + str(num_tries))

const UI_LOCATION = Vector2(100,220)
signal mouse_click(grid_pos, curr_selected_unit)
func _input(event):
	if event is InputEventMouseButton and event.is_action_released("click"):
		if event.position < UI_LOCATION:
			return
		var grid_pos = $TileMap.world_to_map(event.position/2)
		var curr_selected_unit = AUTO.pos_to_unit_map.get(grid_pos, null)
		emit_signal("mouse_click", grid_pos, curr_selected_unit)
	if Input.is_action_just_pressed("ui_accept"):
		show_powerup_change_ui()

func show_powerup_change_ui():
	if $PowerupSelector.visible:
		AUTO.players_set.keys()[0]\
			.set_allowed_attack_enums(\
			HashSet.neww($PowerupSelector.get_selected_powerups()))
	$PowerupSelector.visible = !$PowerupSelector.visible

var prev_selected_unit: Node2D = null
var is_selecting_attack := false
func process_input(grid_pos: Vector2, curr_selected_unit: Unit) -> void:
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
