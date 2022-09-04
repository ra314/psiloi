extends Node

var pos_to_unit_map: Dictionary = {}
const BLOCKING_TILES = {0:true, -1:true}
enum TEAM {UNSET, PLAYER, ENEMY}
enum ATTACK {STAB, ARCHER, BOMBER, WIZARD}
var stationary_attacks = HashSet.neww([ATTACK.ARCHER, ATTACK.BOMBER, ATTACK.WIZARD])

var all_units: Array
var enemies_set: Dictionary
var players_set: Dictionary

func get_units_by_team_enum(team_enum) -> Dictionary:
	assert(team_enum != TEAM.UNSET)
	if team_enum == TEAM.ENEMY:
		return enemies_set
	return players_set

func get_other_team_enum(team_enum):
	assert(team_enum != TEAM.UNSET)
	if team_enum == TEAM.ENEMY:
		return TEAM.PLAYER
	return TEAM.ENEMY
