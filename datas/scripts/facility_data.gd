class_name FacilityData extends Resource

@export_category("Facility Info")
@export var id: String = ""
@export var display_name: String = "Mouse"
@export var icon: Texture2D

@export_category("Progression")
@export var max_level: int = 50
@export var unlock_coach_level: int = 1

@export_category("Effect")
@export var exp_bonus_per_level: float = 0.02

func get_bonus_at_level(current_level: int) -> float:
	if current_level <= 0: return 0.0
	return min(current_level, max_level) * exp_bonus_per_level
