extends Node

var pos_to_unit_map: Dictionary = {}
const BLOCKING_TILES = {0:true, -1:true}
enum TEAM {UNSET, PLAYER, ENEMY}
enum ATTACK {STAB, SLASH, AXE, ARCHER, BOMBER, WIZARD, SHIELDBASH, LANCE}
var attack_enum_to_impl_map = {ATTACK.ARCHER: ArcherStationaryAttack, \
								ATTACK.BOMBER: BomberStationaryAttack, \
								ATTACK.SHIELDBASH: ShieldBashStationaryAttack, \
								ATTACK.WIZARD: WizardStationaryAttack, \
								ATTACK.LANCE: LanceStationaryAttack}
var player_attacks = HashSet.neww([ATTACK.STAB, ATTACK.SLASH, ATTACK.AXE, \
							ATTACK.ARCHER, ATTACK.SHIELDBASH, ATTACK.LANCE])
var enemy_attacks = HashSet.neww([ATTACK.STAB, ATTACK.ARCHER, \
								ATTACK.BOMBER, ATTACK.WIZARD])
func get_allowed_attacks(team_enum) -> Dictionary:
	if team_enum == TEAM.PLAYER:
		return player_attacks
	elif team_enum == TEAM.ENEMY:
		return enemy_attacks
	else:
		assert(false)
	return {}


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

func add_childv2(x, y):
	x.add_child(y)
	return y

func random_int_vector(x_lim: int, y_lim: int):
	return Vector2(randi()%x_lim, randi()%y_lim)


var bombs = HashSet.neww([])
