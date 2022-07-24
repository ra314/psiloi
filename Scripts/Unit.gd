extends Node2D
class_name Unit

var grid_pos: Vector2
var tilemap: TileMap
var curr_path: Array
const MOVEMENT_PERIOD := 0.2
var timer: Timer


func init(tilemap: TileMap, grid_pos: Vector2) -> Unit:
	self.tilemap = tilemap
	self.grid_pos = grid_pos
	position = tilemap.map_to_world(grid_pos)
	AUTO.pos_to_unit_map[grid_pos] = self
	
	timer = Timer.new()
	timer.wait_time = MOVEMENT_PERIOD
	timer.stop()
	timer.connect("timeout", self, "move_along_path")
	add_child(timer)
	
	return self

# Return true if the movement is possible
func move_with_bfs_to(end_grid_pos: Vector2) -> bool:
	# If already moving, don't move again
	if curr_path != []:
		return false
		
	var path = NAVIGATOR.bfs_path(grid_pos, end_grid_pos, tilemap)
	if path == []:
		return false
	curr_path = path
	start_movement()
	return true

func start_movement():
	timer.start()

func check_and_perform_stab_attack(prev_grid_pos: Vector2) -> void:
	var target_grid_pos = NAVIGATOR.get_next_grid_pos_in_same_dir(prev_grid_pos, grid_pos)
	if !(target_grid_pos in AUTO.pos_to_unit_map):
		return
	var enemy: Unit = AUTO.pos_to_unit_map[target_grid_pos]
	enemy.die()

func move_along_path() -> void:
	var node: Vector2 = curr_path.pop_front()
	position = tilemap.map_to_world(node)
	AUTO.pos_to_unit_map.erase(grid_pos)
	var prev_pos = grid_pos
	grid_pos = node
	AUTO.pos_to_unit_map[grid_pos] = self
	
	if curr_path == []:
		check_and_perform_stab_attack(prev_pos)
		timer.stop()
		return

func die():
	visible = false
	AUTO.pos_to_unit_map.erase(grid_pos)

### ATTACKING
var is_attack_highlight_on := false
const WIZARD_BLAST_RANGE := 6
const ARCHER_ATTACK_RANGE := 5
const BOMBER_THROW_RANGE := 2
var possible_attack_tiles: Array 

# Returns false if higlighting is being performed
# Return true if highlighting is over or was not necessary
func stationary_attack(grid_pos: Vector2 = Vector2(0,0)) -> bool:
	return bomber_attack(grid_pos)

func bomber_throw_highlight():
	possible_attack_tiles = \
		NAVIGATOR.get_grid_positions_within_distance(grid_pos, BOMBER_THROW_RANGE)
	tilemap.highlight_tiles(possible_attack_tiles)
	is_attack_highlight_on = true

func bomber_attack(target_grid_pos: Vector2) -> bool:
	if !is_attack_highlight_on:
		bomber_throw_highlight()
		return false
	tilemap.unhighlight_prev_tiles()
	is_attack_highlight_on = false
	# No attack can be performed because the selected position, was not one of the
	# previously highlighted and valid positions for an attack
	if !(target_grid_pos in possible_attack_tiles):
		return true
	possible_attack_tiles = []
	if !(target_grid_pos in AUTO.pos_to_unit_map):
		if !(tilemap.get_cellv(target_grid_pos) in AUTO.BLOCKING_TILES):
			add_bomb(target_grid_pos)
	return true

var BOMB = load("res://Scenes/Bomb.tscn")
func add_bomb(target_grid_pos: Vector2):
	var new_bomb = BOMB.instance().init(tilemap, target_grid_pos)
	get_parent().add_child(new_bomb)

func archer_attack_highlight():
	possible_attack_tiles = \
		NAVIGATOR.get_radial_grid_positions_with_range(grid_pos, ARCHER_ATTACK_RANGE)
	tilemap.highlight_tiles(possible_attack_tiles)
	is_attack_highlight_on = true

func archer_attack(target_grid_pos: Vector2) -> bool:
	if !is_attack_highlight_on:
		archer_attack_highlight()
		return false
	tilemap.unhighlight_prev_tiles()
	is_attack_highlight_on = false
	# No attack can be performed because the selected position, was not one of the
	# previously highlighted and valid positions for an attack
	if !(target_grid_pos in possible_attack_tiles):
		return true
	possible_attack_tiles = []
	if target_grid_pos in AUTO.pos_to_unit_map:
		AUTO.pos_to_unit_map[target_grid_pos].die()
	return true

func wizard_blast_highlight():
	possible_attack_tiles = \
		NAVIGATOR.get_radial_grid_positions_with_range(grid_pos, WIZARD_BLAST_RANGE)
	tilemap.highlight_tiles(possible_attack_tiles)
	is_attack_highlight_on = true

func wizard_blast(target_grid_pos: Vector2) -> bool:
	if !is_attack_highlight_on:
		wizard_blast_highlight()
		return false
	tilemap.unhighlight_prev_tiles()
	is_attack_highlight_on = false
	# No attack can be performed because the selected position, was not one of the
	# previously highlighted and valid positions for an attack
	if !(target_grid_pos in possible_attack_tiles):
		return true
	possible_attack_tiles = []
	var attack_direction = NAVIGATOR.get_direction_between_positions(grid_pos, target_grid_pos)
	# No attack can be performed because the selected point is not in a straight line.
	# Should not be possible since a previous check checks if the selected position
	# is part of the previously highlighted positions
	if attack_direction == "":
		assert(false)
		return true
	for attacked_grid_pos in \
		NAVIGATOR.get_grid_positions_along_line(grid_pos, WIZARD_BLAST_RANGE, attack_direction):
		if attacked_grid_pos in AUTO.pos_to_unit_map:
			AUTO.pos_to_unit_map[attacked_grid_pos].die()
	return true
