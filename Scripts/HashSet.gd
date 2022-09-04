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

# Assumes both sets are similarly sized
static func intersection(set1: Dictionary, set2: Dictionary) -> Array:
	var retval = []
	for item in set1:
		if item in set2:
			retval.append(item)
	return retval
