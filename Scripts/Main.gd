extends Node2D

const HERO_SPAWN_POS := Vector2(0,6)
const ENEMY_SPAWN_POS1 := Vector2(3,3)
const ENEMY_SPAWN_POS2 := Vector2(3,4)
const EXIT_POS := Vector2(6,6)

var PLAYER = load("res://Scenes/Player.tscn")
var ENEMY = load("res://Scenes/Enemy.tscn")

onready var TurnManager = $TurnManager

# Called when the node enters the scene tree for the first time.
func _ready():
	#create_valid_procedural_level()
	#static_initialize_units()
	
	LevelGenerator.apply_random_level_to_tilemap($TileMap)
	yield(dynamic_initialize_units(), "completed")
	
	AUTO.players_set.keys()[0].can_move = true
	connect("mouse_click", self, "process_input")

func dynamic_initialize_units() -> void:
	var label = Label.new()
	add_child(label)
	
	$PowerupSelector.visible = true
	$PowerupSelector.init(AUTO.ATTACK.keys())
	
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
	$Exit.position = $TileMap.map_to_world(get_random_non_blocking_tile())

func get_random_non_blocking_tile() -> Vector2:
	var SEARCH_LIMIT = 1000
	var count = 0
	var curr_pos = Vector2(-1,-1)
	while $TileMap.get_cellv(curr_pos) in AUTO.BLOCKING_TILES:
		curr_pos = Vector2(randi()%(int(LevelGenerator.LEVEL_SIZE.x)), \
							randi()%(int(LevelGenerator.LEVEL_SIZE.y)))
		count += 1
		assert(count < SEARCH_LIMIT)
	return curr_pos

func static_initialize_units() -> void:
	var player = AUTO.add_childv2($Units, PLAYER.instance()).init($TileMap, HERO_SPAWN_POS, \
		AUTO.TEAM.PLAYER, HashSet.neww([AUTO.ATTACK.STAB, AUTO.ATTACK.ARCHER]))
	var enemy1 = AUTO.add_childv2($Units, ENEMY.instance()).init($TileMap, ENEMY_SPAWN_POS1, \
		AUTO.TEAM.ENEMY, HashSet.neww([AUTO.ATTACK.SLASH]))
	var enemy2 = AUTO.add_childv2($Units, ENEMY.instance()).init($TileMap, ENEMY_SPAWN_POS2, \
		AUTO.TEAM.ENEMY, HashSet.neww([AUTO.ATTACK.SLASH]))
	AUTO.players_set = HashSet.neww([player])
	AUTO.enemies_set = HashSet.neww([enemy1, enemy2])
	AUTO.all_units = [player, enemy1, enemy2]
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
		if $TileMap.get_cellv(ENEMY_SPAWN_POS1) in AUTO.BLOCKING_TILES:
			path = []
		if $TileMap.get_cellv(ENEMY_SPAWN_POS2) in AUTO.BLOCKING_TILES:
			path = []
	print("num_tries " + str(num_tries))
	$TileMap.highlight_path(path)

const UI_LOCATION = Vector2(100,220)
signal mouse_click(grid_pos, curr_selected_unit)
func _input(event):
	if event is InputEventMouseButton and event.is_action_released("click"):
		if event.position < UI_LOCATION:
			return
		var grid_pos = $TileMap.world_to_map(event.position)
		var curr_selected_unit = AUTO.pos_to_unit_map.get(grid_pos, null)
		emit_signal("mouse_click", grid_pos, curr_selected_unit)

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
