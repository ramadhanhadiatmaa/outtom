extends Node

const MAX_OFFLINE_SECONDS: int = 14400

func calculate_offline_delta(last_unix_time: int) -> int:
	if last_unix_time <= 0:
		return 0

	var current_time: int = get_current_unix_time()
	var delta: int = current_time - last_unix_time

	if delta < 0:
		return 0
	return clampi(delta, 0, MAX_OFFLINE_SECONDS)

func get_current_unix_time() -> int:
	return int(Time.get_unix_time_from_system())
