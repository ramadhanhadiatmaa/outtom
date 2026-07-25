extends Node

const MAX_SESSION_SECONDS: int = 14400

var _time_accumulator: float = 0.0
var _base_exp_per_second: int = 5

func _ready() -> void:
	set_process(false)
	call_deferred("_process_offline_gains")

# ==========================================
# PUBLIC API
# ==========================================

func start_activity(activity_id: String) -> void:
	var save: SaveData = SaveManager.current_save

	if save.active_activity_id != "":
		stop_activity()

	var current_level: int = save.get_activity_level(activity_id)
	if current_level >= 100:
		push_warning("TrainingManager: Activity already at max level.")
		return

	save.active_activity_id = activity_id
	save.active_session_elapsed = 0
	set_process(true)

	SaveManager.save_game()
	SignalBus.training_started.emit(activity_id)

func stop_activity() -> void:
	var save: SaveData = SaveManager.current_save

	if save.active_activity_id == "":
		return

	var stopped_id: String = save.active_activity_id

	save.active_activity_id = ""
	save.active_session_elapsed = 0
	set_process(false)

	SaveManager.save_game()
	SignalBus.training_stopped.emit(stopped_id)

# ==========================================
# INTERNAL LOGIC
# ==========================================

func _process(delta: float) -> void:
	var save: SaveData = SaveManager.current_save
	if save.active_activity_id == "":
		set_process(false)
		return

	_time_accumulator += delta

	if _time_accumulator >= 1.0:
		var ticks: int = int(_time_accumulator)
		_time_accumulator -= ticks
		_apply_exp_gain(save.active_activity_id, ticks)

func _process_offline_gains() -> void:
	var save: SaveData = SaveManager.current_save
	if save.active_activity_id == "":
		return

	var offline_seconds: int = TimeManager.calculate_offline_delta(save.last_offline_timestamp)

	if offline_seconds > 0:
		_apply_exp_gain(save.active_activity_id, offline_seconds)

	if save.active_session_elapsed < MAX_SESSION_SECONDS:
		set_process(true)

func _apply_exp_gain(activity_id: String, seconds_elapsed: int) -> void:
	var save: SaveData = SaveManager.current_save
	var time_remaining_in_session: int = MAX_SESSION_SECONDS - save.active_session_elapsed
	var actual_seconds_to_process: int = mini(seconds_elapsed, time_remaining_in_session)

	if actual_seconds_to_process <= 0:
		stop_activity()
		return

	save.active_session_elapsed += actual_seconds_to_process

	var total_multiplier: float = 1.0
	var exp_gained: int = int(actual_seconds_to_process * _base_exp_per_second * total_multiplier)

	if not save.activity_exp.has(activity_id):
		save.activity_exp[activity_id] = 0

	save.activity_exp[activity_id] += exp_gained
	_check_level_up(activity_id)
	SignalBus.exp_ticked.emit(activity_id, exp_gained)

	if save.active_session_elapsed >= MAX_SESSION_SECONDS:
		stop_activity()

func _check_level_up(activity_id: String) -> void:
	var save: SaveData = SaveManager.current_save
	var current_level: int = save.get_activity_level(activity_id)
	var current_exp: int = save.activity_exp[activity_id]
	var leveled_up: bool = false

	while current_level < 100:
		var exp_needed: int = get_exp_required(current_level)
		if current_exp >= exp_needed:
			current_exp -= exp_needed
			current_level += 1
			leveled_up = true
		else:
			break

	if leveled_up:
		save.activity_levels[activity_id] = current_level
		save.activity_exp[activity_id] = current_exp
		SignalBus.coach_leveled_up.emit(activity_id, current_level)

func get_exp_required(level: int) -> int:
	if level >= 100:
		return 999999999
	if level <= 50:
		return int(100.0 * pow(1.08, float(level - 1)))
	else:
		var exp_50: float = 100.0 * pow(1.08, 49.0)
		return int(exp_50 * pow(1.13, float(level - 50)))
