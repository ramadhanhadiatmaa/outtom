extends Control

@export var title_label: Label 
@export var level_label: Label 
@export var exp_progress: ProgressBar 
@export var start_button: Button 
@export var stop_button: Button 

var current_activity_id: String = "basic_training" 

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	stop_button.pressed.connect(_on_stop_pressed)

	SignalBus.training_started.connect(_on_training_started)
	SignalBus.training_stopped.connect(_on_training_stopped)
	SignalBus.exp_ticked.connect(_on_exp_ticked)
	SignalBus.coach_leveled_up.connect(_on_coach_leveled_up)

	_refresh_visual_state()

# ==========================================
# USER INPUT HANDLING
# ==========================================

func _on_start_pressed() -> void:
	TrainingManager.start_activity(current_activity_id)

func _on_stop_pressed() -> void:
	TrainingManager.stop_activity()

# ==========================================
# SIGNAL RESPONDERS
# ==========================================

func _on_training_started(activity_id: String) -> void:
	if activity_id != current_activity_id: return
	start_button.disabled = true
	stop_button.disabled = false
	title_label.text = "Training Active: " + activity_id

func _on_training_stopped(activity_id: String) -> void:
	if activity_id != current_activity_id: return
	start_button.disabled = false
	stop_button.disabled = true
	title_label.text = "Idle: " + activity_id

func _on_exp_ticked(activity_id: String, _exp_gained: int) -> void:
	if activity_id != current_activity_id: return
	var save: SaveData = SaveManager.current_save
	var current_exp: int = save.activity_exp.get(activity_id, 0)
	exp_progress.value = current_exp

func _on_coach_leveled_up(activity_id: String, new_level: int) -> void:
	if activity_id != current_activity_id: return
	level_label.text = "Level: " + str(new_level)
	_refresh_visual_state()

# ==========================================
# HELPER FUNCTIONS
# ==========================================

func _refresh_visual_state() -> void:
	var save: SaveData = SaveManager.current_save
	var level: int = save.get_activity_level(current_activity_id)
	var exp: int = save.activity_exp.get(current_activity_id, 0)
	var max_exp: int = TrainingManager.get_exp_required(level)

	level_label.text = "Level: " + str(level)
	exp_progress.max_value = max_exp
	exp_progress.value = exp

	if save.active_activity_id == current_activity_id:
		_on_training_started(current_activity_id)
	else:
		_on_training_stopped(current_activity_id)
