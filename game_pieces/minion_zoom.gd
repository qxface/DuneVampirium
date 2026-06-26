class_name MinionZoom
extends Minion

func _ready() -> void:
	super()
	_sb_normal = preload("uid://bu1rg8kneo1au")
	_sb_selected = preload("uid://bu1rg8kneo1au")

func _populate_action_icons() -> void:
	if card_data == null:
		return
	ActionDisplay.populate(acquire_panel, card_data.acquire_effects, card_data.acquire_cost, card_data.acquire_requirement)
	ActionDisplay.populate(agent_panel,   card_data.agent_effects,   card_data.agent_cost,   card_data.agent_requirement)
	ActionDisplay.populate(reveal_panel,  card_data.reveal_effects,  card_data.reveal_cost,  card_data.reveal_requirement)
	ActionDisplay.populate(discard_panel, card_data.discard_effects, card_data.discard_cost, card_data.discard_requirement)
	ActionDisplay.populate(trash_panel,   card_data.trash_effects,   card_data.trash_cost,   card_data.trash_requirement)
