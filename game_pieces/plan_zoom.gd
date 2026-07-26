class_name PlanZoom
extends Plan

func _ready() -> void:
	super()
	name_panel.visible = true
	_sb_normal = preload("uid://cqi7cm2f5o78c")
	_sb_selected = preload("uid://cqi7cm2f5o78c")

func _populate_action_icons() -> void:
	if card_data == null:
		return
	ActionDisplay.populate(acquire_panel, card_data.acquire_effects, card_data.acquire_cost, card_data.acquire_cost_amount, card_data.acquire_requirement, card_data.acquire_requirement_amount)
	ActionDisplay.populate(agent_panel,   card_data.agent_effects,   card_data.agent_cost,   card_data.agent_cost_amount,   card_data.agent_requirement,   card_data.agent_requirement_amount)
	ActionDisplay.populate(reveal_panel,  card_data.reveal_effects,  card_data.reveal_cost,  card_data.reveal_cost_amount,  card_data.reveal_requirement,  card_data.reveal_requirement_amount)
	ActionDisplay.populate(discard_panel, card_data.discard_effects, card_data.discard_cost, card_data.discard_cost_amount, card_data.discard_requirement, card_data.discard_requirement_amount)
	ActionDisplay.populate(trash_panel,   card_data.trash_effects,   card_data.trash_cost,   card_data.trash_cost_amount,   card_data.trash_requirement,   card_data.trash_requirement_amount)
