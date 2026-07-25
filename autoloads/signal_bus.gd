extends Node

signal exp_gained(amount: int)
signal training_completed(activity_id: String)
signal player_recruited(card_data: Resource)
signal training_started(activity_id: String)
signal training_stopped(activity_id: String)
signal exp_ticked(activity_id: String, exp_gained: int)
signal coach_leveled_up(activity_id: String, new_level: int)

signal gacha_pull_success(card_data: PlayerCardData)
signal gacha_pull_failed(reason: String)

signal cards_fused(new_card_data: PlayerCardData)
signal card_dismantled(card_id: String, fragments_gained: int)
