extends Node2D

var _turn_count := 0

func increase_turn_count() -> void:
	_turn_count += 1
	$Label.text = "TURN: " + str(_turn_count)
	get_parent().reset_move_over_for_all_units()

func get_turn_count() -> int:
	return _turn_count
