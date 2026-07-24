class_name CoachActivityData extends Resource

enum ActivityCategory { COMBAT, VISION, STRATEGY, PHYSICAL, EQUIPMENT, SPECIAL }

@export_category("Activity Definition")
@export var id: String = ""
@export var display_name: String = "Training Activity"
@export_multiline var description: String = ""
@export var category: ActivityCategory = ActivityCategory.COMBAT
@export var icon: Texture2D

@export_category("Mechanics")
@export var required_coach_level: int = 1
