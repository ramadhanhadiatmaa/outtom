extends Node

const SAVE_PATH: String = "user://coach_save.res"

var current_save: SaveData

func _ready() -> void:
	load_game()

func save_game() -> void:
	if current_save == null:
		push_warning("SaveManager: current_save kosong, membatalkan proses save.")
		return
	current_save.last_offline_timestamp = TimeManager.get_current_unix_time()

	var error: int = ResourceSaver.save(current_save, SAVE_PATH)

	if error != OK:
		push_error("SaveManager: Gagal menyimpan data game! Error code: ", error)
	else:
		print("SaveManager: Game berhasil disimpan.")

func load_game() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		current_save = ResourceLoader.load(SAVE_PATH) as SaveData
	if current_save == null:
		push_warning("SaveManager: Save file not found or corrupted. Creating a new SaveData instance...")
		current_save = SaveData.new()
		if TimeManager:
			current_save.last_offline_timestamp = TimeManager.get_current_unix_time()
		save_game()
	else:
		print("SaveManager: Save data loaded successfully.")
