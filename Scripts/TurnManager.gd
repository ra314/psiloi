extends Node2D

var _turn_count := 0
var _ply_count := 0
var _is_player_turn := true
var Main = get_parent()

func increment_turn_count() -> void:
	_turn_count += 1
	$Label.text = "TURN: " + str(_turn_count)

func get_turn_count() -> int:
	return _turn_count

# Argument represent the team that is currently active
func increment_ply_count(team_enum) -> void:
	_ply_count += 1
	for unit in AUTO.get_units_by_team_enum(team_enum):
		unit.can_move = false
	var opposing_team_enum = AUTO.get_other_team_enum(team_enum)
	for unit in AUTO.get_units_by_team_enum(opposing_team_enum):
		unit.can_move = true
	if _ply_count%2 == 0:
		increment_turn_count()

# Argument represent the team that is currently active
func check_ply_over(team_enum) -> bool:
	for unit in AUTO.get_units_by_team_enum(team_enum):
		if unit.can_move:
			return false
	return true
