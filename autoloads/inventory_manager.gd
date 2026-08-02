extends Node

const FRAGMENT_VALUES: Dictionary = {
	PlayerCardData.Rarity.COMMON: 1,
	PlayerCardData.Rarity.UNCOMMON: 2,
	PlayerCardData.Rarity.RARE: 3,
	PlayerCardData.Rarity.EPIC: 10,
	PlayerCardData.Rarity.LEGENDARY: 30,
	PlayerCardData.Rarity.MYTHIC: 100
}

# ==========================================
# PUBLIC API: FUSION
# ==========================================
func fuse_cards(card_ids: Array[String]) -> bool:
	if card_ids.size() != 4:
		push_warning("InventoryManager: Fusion requires exactly 4 cards.")
		return false
	var save: SaveData = SaveManager.current_save
	var cards_to_fuse: Array[PlayerCardData] = []

	for id in card_ids:
		var card: PlayerCardData = _get_card_by_id(id, save.owned_players)
		if card == null:
			push_error("InventoryManager: Card ID not found in roster.")
			return false
		cards_to_fuse.append(card)

	var target_rarity: PlayerCardData.Rarity = cards_to_fuse[0].rarity
	if target_rarity == PlayerCardData.Rarity.MYTHIC:
		push_warning("InventoryManager: Cannot fuse Mythic cards.")
		return false

	for card in cards_to_fuse:
		if card.rarity != target_rarity:
			push_warning("InventoryManager: All cards must be of the same rarity.")
			return false

	for card in cards_to_fuse:
		save.owned_players.erase(card)
	var new_rarity: PlayerCardData.Rarity = (target_rarity + 1) as PlayerCardData.Rarity
	var new_card: PlayerCardData = GachaManager.pull_card_from_pool(new_rarity)
	if new_card != null:
		save.owned_players.append(new_card)
		SaveManager.save_game()
		SignalBus.cards_fused.emit(new_card)
		return true
	else:
		push_error("InventoryManager: Fusion failed due to empty card pool.")
		return false

# ==========================================
# PUBLIC API: DISMANTLE
# ==========================================
func dismantle_card(card_id: String) -> bool:
	var save: SaveData = SaveManager.current_save
	var card: PlayerCardData = _get_card_by_id(card_id, save.owned_players)

	if card == null:
		push_error("InventoryManager: Cannot dismantle, card not found.")
		return false

	var fragments_earned: int = FRAGMENT_VALUES[card.rarity]
	save.owned_players.erase(card)
	save.potential_fragments += fragments_earned
	SaveManager.save_game()
	SignalBus.card_dismantled.emit(card_id, fragments_earned)

	return true

# ==========================================
# INTERNAL HELPERS
# ==========================================
func _get_card_by_id(id: String, roster: Array[PlayerCardData]) -> PlayerCardData:
	for card in roster:
		if card.id == id:
			return card
	return null
