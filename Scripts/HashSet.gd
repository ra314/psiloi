class_name HashSet

static func neww(values: Array):
	var set = {}
	for value in values:
		set[value] = true
	return set

static func add(set: Dictionary, value):
	set[value] = true

static func remove(set: Dictionary, value):
	if value in set:
		set.erase(value)
		return true
	return false
