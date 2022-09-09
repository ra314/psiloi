class_name LevelGenerator

const LEVEL_SIZE = Vector2(20,20)
const HIGHEST_INT_TILE_VALUE := 1

static func init_noise() -> OpenSimplexNoise:
	var noise = OpenSimplexNoise.new()
	randomize()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 2
	noise.persistence = 0.8
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

static func apply_random_level_to_tilemap(tilemap: TileMap) -> void:
	var procedural_level = generate_level()
	for i in range(len(procedural_level)):
		for j in range(len(procedural_level[0])):
			tilemap.set_cell(i, j, procedural_level[i][j])
