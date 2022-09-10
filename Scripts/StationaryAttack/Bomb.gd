extends Sprite

var Main
var ply_countdown := 2
var grid_pos: Vector2
var tilemap: TileMap

func init(Main, grid_pos, tilemap):
	self.Main = Main
	self.grid_pos = grid_pos
	self.tilemap = tilemap
	position = tilemap.map_to_world(grid_pos)
	return self

func decrement_ply_countdown():
	ply_countdown -= 1
	if ply_countdown == 0:
		explode()

func explode():
	var target_tiles = NAVIGATOR.get_surrounding_tiles(grid_pos)
	for tile in target_tiles:
		var target_unit = AUTO.pos_to_unit_map.get(tile, null)
		if target_unit:
			target_unit.die()
	HashSet.remove(AUTO.bombs, self)
	queue_free()
