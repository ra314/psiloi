extends Node

var _turn_count := 0

func increase_turn_count() -> void:
	_turn_count += 1

func get_turn_count() -> int:
	return _turn_count
