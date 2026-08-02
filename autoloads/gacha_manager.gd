extends Node

const RATE_COMMON: float = 49.0
const RATE_UNCOMMON: float = 26.0
const RATE_RARE: float = 15.0
const RATE_EPIC: float = 7.0
const RATE_LEGENDARY: float = 2.6
const RATE_MYTHIC: float = 0.4

const PITY_EPIC: int = 40
const PITY_LEGENDARY: int = 100
const PITY_MYTHIC: int = 500

const PULL_COST: int = 1

@export_category("Card Database (Pools)")
@export var pool_common: Array[PlayerCardData] = []
@export var pool_uncommon: Array[PlayerCardData] = []
@export var pool_rare: Array[PlayerCardData] = []
@export var pool_epic: Array[PlayerCardData] = []
@export var pool_legendary: Array[PlayerCardData] = []
@export var pool_mythic: Array[PlayerCardData] = []

# ==========================================
# PUBLIC API
# ==========================================
func pull_single() -> void:
	var save: SaveData = SaveManager.current_save

	if save.scout_tokens < PULL_COST:
		SignalBus.gacha_pull_failed.emit("Not enough Scout Tokens.")
		return

	var rolled_rarity: PlayerCardData.Rarity = _roll_rarity(save)
	var new_card: PlayerCardData = pull_card_from_pool(rolled_rarity)

	if new_card == null:
		SignalBus.gacha_pull_failed.emit("System Error: Card pool is empty.")
		return

	save.scout_tokens -= PULL_COST
	save.owned_players.append(new_card)
	SaveManager.save_game()
	SignalBus.gacha_pull_success.emit(new_card)

func pull_card_from_pool(rarity: PlayerCardData.Rarity) -> PlayerCardData:
	var selected_pool: Array[PlayerCardData] = _get_pool_by_rarity(rarity)

	if selected_pool.is_empty():
		push_error("GachaManager: Card pool for rarity %s is empty!" % rarity)
		return null

	var random_index: int = randi() % selected_pool.size()
	var base_card: PlayerCardData = selected_pool[random_index]
	var unique_instance: PlayerCardData = base_card.duplicate(true) as PlayerCardData
	unique_instance.id = _generate_uuid()
	return unique_instance

# ==========================================
# INTERNAL LOGIC & RNG
# ==========================================
func _roll_rarity(save: SaveData) -> PlayerCardData.Rarity:
	save.pity_epic_counter += 1
	save.pity_legendary_counter += 1
	save.pity_mythic_counter += 1

	var final_rarity: PlayerCardData.Rarity = PlayerCardData.Rarity.COMMON
	if save.pity_mythic_counter >= PITY_MYTHIC:
		final_rarity = PlayerCardData.Rarity.MYTHIC
	elif save.pity_legendary_counter >= PITY_LEGENDARY:
		final_rarity = PlayerCardData.Rarity.LEGENDARY
	elif save.pity_epic_counter >= PITY_EPIC:
		final_rarity = PlayerCardData.Rarity.EPIC
	else:
		var roll: float = randf_range(0.0, 100.0)
		if roll <= RATE_MYTHIC:
			final_rarity = PlayerCardData.Rarity.MYTHIC
		elif roll <= RATE_MYTHIC + RATE_LEGENDARY:
			final_rarity = PlayerCardData.Rarity.LEGENDARY
		elif roll <= RATE_MYTHIC + RATE_LEGENDARY + RATE_EPIC:
			final_rarity = PlayerCardData.Rarity.EPIC
		elif roll <= RATE_MYTHIC + RATE_LEGENDARY + RATE_EPIC + RATE_RARE:
			final_rarity = PlayerCardData.Rarity.RARE
		elif roll <= RATE_MYTHIC + RATE_LEGENDARY + RATE_EPIC + RATE_RARE + RATE_UNCOMMON:
			final_rarity = PlayerCardData.Rarity.UNCOMMON
		else:
			final_rarity = PlayerCardData.Rarity.COMMON
	_reset_pity_counters(save, final_rarity)
	return final_rarity

func _reset_pity_counters(save: SaveData, obtained_rarity: PlayerCardData.Rarity) -> void:
	match obtained_rarity:
		PlayerCardData.Rarity.MYTHIC:
			save.pity_mythic_counter = 0
			save.pity_legendary_counter = 0
			save.pity_epic_counter = 0
		PlayerCardData.Rarity.LEGENDARY:
			save.pity_legendary_counter = 0
			save.pity_epic_counter = 0
		PlayerCardData.Rarity.EPIC:
			save.pity_epic_counter = 0

func _get_pool_by_rarity(rarity: PlayerCardData.Rarity) -> Array[PlayerCardData]:
	match rarity:
		PlayerCardData.Rarity.COMMON: return pool_common
		PlayerCardData.Rarity.UNCOMMON: return pool_uncommon
		PlayerCardData.Rarity.RARE: return pool_rare
		PlayerCardData.Rarity.EPIC: return pool_epic
		PlayerCardData.Rarity.LEGENDARY: return pool_legendary
		PlayerCardData.Rarity.MYTHIC: return pool_mythic
		_: return []

func _generate_uuid() -> String:
	var chars: String = "abcdefghijklmnopqrstuvwxyz0123456789"
	var uuid: String = str(Time.get_unix_time_from_system()) + "_"
	for i in range(6):
		uuid += chars[randi() % chars.length()]
	return uuid
