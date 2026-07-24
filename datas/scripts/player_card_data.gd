class_name PlayerCardData extends Resource

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC }
enum Playstyle { AGGRESSOR, FARMER, TACTICIAN, CLUTCH, SUPPORTIVE, VERSATILE }
enum Mentality { STEADY, HOTHEAD, ICE_COLD, LEADER, ROOKIE, VETERAN }

@export_category("Player Identity")
@export var id: String = ""
@export var player_name: String = "Rookie Player"
@export var portrait: Texture2D

@export_category("Base Attributes")
@export var rarity: Rarity = Rarity.COMMON
@export var playstyle: Playstyle = Playstyle.VERSATILE
@export var mentality: Mentality = Mentality.STEADY

@export_category("Career & Progression")
@export var active_season: int = 1
@export var is_retired: bool = false

func get_max_cap() -> float:
	match rarity:
		Rarity.COMMON: return 0.80
		Rarity.UNCOMMON: return 0.85
		Rarity.RARE: return 0.90
		Rarity.EPIC: return 0.95
		Rarity.LEGENDARY, Rarity.MYTHIC: return 1.00
		_: return 0.80
