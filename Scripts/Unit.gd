extends Node2D
class_name Unit

var grid_pos: Vector2
var tilemap: TileMap
var curr_path: Array
const MOVEMENT_PERIOD := 0.2
var timer: Timer

var _allowed_attack_enums: Dictionary
var _stationary_attack_implementation: StationaryAttackInterface
func set_allowed_attack_enums(allowed_attack_enums: Dictionary):
	if team_enum == AUTO.TEAM.ENEMY:
		# Enemies can only have a single attack
		assert(len(allowed_attack_enums)==1)
		# Enemies can't slash
		assert(!(AUTO.ATTACK.SLASH in allowed_attack_enums))
	
	# Validate that non allowed attack enums aren't selected
	var legal_attacks = AUTO.get_allowed_attacks(team_enum)
	assert(len(allowed_attack_enums) == \
		len(HashSet.intersection(allowed_attack_enums, legal_attacks)))
	
	_allowed_attack_enums = allowed_attack_enums
	_stationary_attack_implementation = get_stationary_attack_implementation(_allowed_attack_enums)
	init_sprite(_allowed_attack_enums)
var team_enum = AUTO.TEAM.UNSET
var can_move := false
var Main


const STARTING_HEALTH = 3
var _health: int
func set_health(value: int):
	$Health.text = str(value)
	_health = value

func init(tilemap: TileMap, grid_pos: Vector2, team_enum, allowed_attack_enums: Dictionary) -> Unit:
	self.tilemap = tilemap
	self.team_enum = team_enum
	self.grid_pos = grid_pos
	set_allowed_attack_enums(allowed_attack_enums)
	
	if team_enum == AUTO.TEAM.PLAYER:
		$Health.visible = true
		set_health(STARTING_HEALTH)
	
	position = tilemap.map_to_world(grid_pos)
	AUTO.pos_to_unit_map[grid_pos] = self
	Main = get_parent().get_parent()
	return self

var E_ARCHER_TEX = load("res://Assets/Units/Enemy/Unit_Enemy_Archer.png")
var E_BOMBER_TEX = load("res://Assets/Units/Enemy/Unit_Enemy_Bomber.png")
var E_MINION_TEX = load("res://Assets/Units/Enemy/Unit_Enemy_Minion.png")
var E_WIZARD_TEX = load("res://Assets/Units/Enemy/Unit_Enemy_Wizard.png")
func init_enemy_sprite(_allowed_attack_enums: Dictionary) -> void:
	if AUTO.ATTACK.ARCHER in _allowed_attack_enums:
		self.texture = E_ARCHER_TEX
	elif AUTO.ATTACK.BOMBER in _allowed_attack_enums:
		self.texture = E_BOMBER_TEX
	elif (AUTO.ATTACK.STAB in _allowed_attack_enums) or \
		(AUTO.ATTACK.SLASH in _allowed_attack_enums):
		self.texture = E_MINION_TEX
	elif AUTO.ATTACK.WIZARD in _allowed_attack_enums:
		self.texture = E_WIZARD_TEX

var P_SWORD_TEX = load("res://Assets/Units/Player/Unit_Player_Sword.png")
var P_AXE_TEX = load("res://Assets/Units/Player/Unit_Player_Axe.png")
var P_ARCHER_TEX = load("res://Assets/Units/Player/Unit_Player_Bow.png")
var P_LANCE_TEX = load("res://Assets/Units/Player/Unit_Player_Rapier.png")
var P_SHIELD_TEX = load("res://Assets/Units/Player/Unit_Player_Shield.png")
func init_player_sprite(_allowed_attack_enums: Dictionary) -> void:
	if AUTO.ATTACK.ARCHER in _allowed_attack_enums:
		self.texture = P_ARCHER_TEX
	elif AUTO.ATTACK.LANCE in _allowed_attack_enums:
		self.texture = P_LANCE_TEX
	elif (AUTO.ATTACK.STAB in _allowed_attack_enums) or \
		(AUTO.ATTACK.SLASH in _allowed_attack_enums):
		self.texture = P_SWORD_TEX
	elif AUTO.ATTACK.SHIELDBASH in _allowed_attack_enums:
		self.texture = P_SHIELD_TEX
	elif AUTO.ATTACK.AXE in _allowed_attack_enums:
		self.texture = P_AXE_TEX

func init_sprite(_allowed_attack_enums: Dictionary) -> void:
	if team_enum == AUTO.TEAM.PLAYER:
		init_player_sprite(_allowed_attack_enums)
	elif team_enum == AUTO.TEAM.ENEMY:
		init_enemy_sprite(_allowed_attack_enums)
	else:
		assert(false)

# TODO: This doesn't work with multiple allowed stationary attacks
func get_stationary_attack_implementation(_allowed_attack_enums):
	for attack_enum in _allowed_attack_enums:
		if attack_enum in AUTO.attack_enum_to_impl_map:
			return AUTO.attack_enum_to_impl_map[attack_enum].new()
	return null

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
	timer = Timer.new()
	timer.wait_time = MOVEMENT_PERIOD
	timer.stop()
	timer.connect("timeout", self, "move_along_path")
	add_child(timer)
	timer.start()

# Returns true if the provided unit is on the other tream
func is_unit_on_other_team(unit):
	return unit.team_enum == AUTO.get_other_team_enum(team_enum)

# Attacks if you move directly towards a unit and are now adjacent
func check_and_perform_stab_attack(prev_grid_pos: Vector2) -> void:
	if not (AUTO.ATTACK.STAB in _allowed_attack_enums):
		return
	var target_grid_pos = NAVIGATOR.get_next_grid_pos_in_same_dir(prev_grid_pos, grid_pos)
	if !(target_grid_pos in AUTO.pos_to_unit_map):
		return
	var enemy: Unit = AUTO.pos_to_unit_map[target_grid_pos]
	if is_unit_on_other_team(enemy):
		enemy.die()

# Kills an enemy unit if you were and are adjacent to an enemey unit
func check_and_perform_slash_attack(prev_grid_pos: Vector2) -> void:
	if not (AUTO.ATTACK.SLASH in _allowed_attack_enums):
		return
	var prev_adjacent_poss = NAVIGATOR.get_surrounding_tiles(prev_grid_pos)
	var curr_adjacent_poss = NAVIGATOR.get_surrounding_tiles(grid_pos)
	var target_poss = HashSet.intersection(HashSet.neww(prev_adjacent_poss),\
											HashSet.neww(curr_adjacent_poss))
	for target_grid_pos in target_poss:
		var target_unit = AUTO.pos_to_unit_map.get(target_grid_pos, null)
		if target_unit:
			if is_unit_on_other_team(target_unit):
				target_unit.die()

func move_unit_directly_to(new_grid_pos: Vector2) -> void:
	position = tilemap.map_to_world(new_grid_pos)
	AUTO.pos_to_unit_map.erase(grid_pos)
	grid_pos = new_grid_pos
	AUTO.pos_to_unit_map[grid_pos] = self

func move_along_path() -> void:
	var new_grid_pos: Vector2 = curr_path.pop_front()
	var prev_pos = grid_pos
	move_unit_directly_to(new_grid_pos)
	
	if curr_path == []:
		check_and_perform_stab_attack(prev_pos)
		check_and_perform_slash_attack(prev_pos)
		timer.stop()
		return

func die():
	if _health>1:
		set_health(_health-1)
	else:
		visible = false
		AUTO.pos_to_unit_map.erase(grid_pos)
		AUTO.get_units_by_team_enum(team_enum).erase(self)
		AUTO.all_units.erase(self)

func action_done():
	can_move = false
	if Main.TurnManager.check_ply_over(team_enum):
		Main.TurnManager.increment_ply_count(team_enum)

func stationary_attack(grid_pos) -> bool:
	if _stationary_attack_implementation == null:
		return false
	if not (_stationary_attack_implementation.get_attack_type() in _allowed_attack_enums):
		return false
	if _stationary_attack_implementation.is_attack_highlight_on:
		return _stationary_attack_implementation.perform_attack(grid_pos, tilemap, self)
	var possible_target_tiles = \
		_stationary_attack_implementation.get_possible_target_tiles(grid_pos)
	_stationary_attack_implementation.\
		highlight_possible_target_tiles(possible_target_tiles, tilemap)
	return false

