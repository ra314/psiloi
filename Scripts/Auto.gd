extends Node

var pos_to_unit_map: Dictionary = {}
const BLOCKING_TILES = {0:true, -1:true}
enum TEAM {UNSET, PLAYER, ENEMY}
enum ATTACK {STAB, SLASH, ARCHER, BOMBER, WIZARD, SHIELDBASH, LANCE}
var attack_enum_to_class_map = {ATTACK.ARCHER: ArcherStationaryAttack, \
								ATTACK.BOMBER: BomberStationaryAttack, \
								ATTACK.SHIELDBASH: ShieldBashStationaryAttack, \
								ATTACK.WIZARD: WizardStationaryAttack, \
								ATTACK.LANCE: LanceStationaryAttack}

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
