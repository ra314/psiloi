class_name LevelGenerator

const LEVEL_SIZE = Vector2(20,10)
const HIGHEST_INT_TILE_VALUE := 1

static func init_noise() -> OpenSimplexNoise:
	var noise = OpenSimplexNoise.new()
	randomize()
	noise.seed = randi()
	noise.octaves = 6
	noise.period = 15
	noise.persistence = 0.5
	return noise

static func get_2d_noise_array(noise: OpenSimplexNoise, size: Vector2) -> Array:
	var noise_array = []
	for i in range(size.x):
		noise_array.append([])
		for j in range(size.y):
			noise_array[i].append(noise.get_noise_2d(i,j))
	return noise_array

# Normalize a 2D Array to between 0 and 1
static func normalize_level(level: Array) -> Array:
	var normalized_level = level.duplicate(true)
	var lowest = INF
	var highest = -INF
	for row in normalized_level:
		lowest = min(lowest, row.min())
		highest = max(highest, row.max())
	for i in range(len(normalized_level)):
		for j in range(len(normalized_level[0])):
			normalized_level[i][j] -= lowest
			normalized_level[i][j] /= abs(highest-lowest)
			normalized_level[i][j] *= HIGHEST_INT_TILE_VALUE
	return normalized_level

static func cast_and_round_level_to_ints(level: Array) -> Array:
	var integerized_level = level.duplicate(true)
	for i in range(len(integerized_level)):
		for j in range(len(integerized_level[0])):
			integerized_level[i][j] = int(round(integerized_level[i][j]))
	return integerized_level

# Returns a 2D array of ints. Either 0 or 1.
static func generate_level() -> Array:
	var noise = init_noise()
	var two_d_noise_array = get_2d_noise_array(noise, LEVEL_SIZE)
	var normalized_level = normalize_level(two_d_noise_array)
	return cast_and_round_level_to_ints(normalized_level)

const ABLATION_FACTOR := 0.3
static func generate_level_through_ablation() -> Array:
	randomize()
	var level = []
	# Generation of a blank level full of land
	for i in range(LEVEL_SIZE.x):
		level.append([])
		for j in range(LEVEL_SIZE.y):
			level[i].append(1)
	# Ablation
	var num_tiles_to_remove = int(ABLATION_FACTOR * (LEVEL_SIZE.x * LEVEL_SIZE.y))
	var removed_tiles = HashSet.neww([])
	while num_tiles_to_remove != 0:
		var pos: Vector2
		while true:
			pos = AUTO.random_int_vector(LEVEL_SIZE.x, LEVEL_SIZE.y)
			if pos in removed_tiles:
				continue
			else:
				HashSet.add(removed_tiles, pos)
				break
		level[pos.x][pos.y] = 0
		num_tiles_to_remove -= 1
	return level

static func apply_random_level_to_tilemap(level_array: Array, tilemap: TileMap) -> void:
	for i in range(len(level_array)):
		for j in range(len(level_array[0])):
			tilemap.set_cell(i, j, level_array[i][j])
