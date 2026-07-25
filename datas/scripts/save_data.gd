class_name SaveData extends Resource

@export_category("Currencies & Meta")
@export var gold: int = 0
@export var scout_tokens: int = 0
@export var prestige_tokens: int = 0
@export var legacy_points: int = 0
@export var fan_count: int = 0

@export_category("Coach Progression")
@export var coach_level: int = 1
@export var coach_exp: int = 0

@export_category("Time Management")
@export var last_offline_timestamp: int = 0
@export_category("Player Roster")
@export var owned_players: Array[PlayerCardData] = []

@export_category("Upgrades & Activities")
@export var facility_levels: Dictionary = {}
@export var activity_levels: Dictionary = {}

@export_category("Active Training State")
@export var active_activity_id: String = ""
@export var active_session_elapsed: int = 0
@export var activity_exp: Dictionary = {}

@export_category("Gacha Pity Trackers")
@export var pity_epic_counter: int = 0
@export var pity_legendary_counter: int = 0
@export var pity_mythic_counter: int = 0

@export_category("Inventory & Economy")
@export var potential_fragments: int = 0

# ==========================================
# ENCAPSULATION & DATA HELPERS
# ==========================================

func get_facility_level(id: String) -> int:
	if facility_levels.has(id):
		return facility_levels[id]
	return 1

func get_activity_level(id: String) -> int:
	if activity_levels.has(id):
		return activity_levels[id]
	return 1

func add_player_to_roster(player_card: PlayerCardData) -> void:
	owned_players.append(player_card)
