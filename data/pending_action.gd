class_name PendingAction
extends RefCounted

# One lifecycle action (Acquire/Agent/Reveal/Discard/Trash) from a Minion, Plan, or
# Space that couldn't auto-fire — either because it has a cost (see CardData/SpaceData's
# *_effective_auto_execute) or because its own auto_execute flag was set to false for a
# non-cost reason (e.g. an effect that needs player input, like "Trash 1 Plan").
# GameState builds these; board.gd/PendingActionPrompt present them for the player to
# trigger in whatever order they choose.

var source: Resource        # CardData or SpaceData
var action_name: String     # "Acquire" / "Agent" / "Reveal" / "Discard" / "Trash" — display only
var cost_type: GameEnums.CostType
var cost_amount: int
var effects: Array          # Array[Effect]
var effective_auto_execute: bool = true  # set by GameState._make_pending_action(); false means this needs a player choice

func has_cost() -> bool:
	return cost_type != GameEnums.CostType.NONE and cost_amount > 0

func source_name() -> String:
	if source is CardData:
		return (source as CardData).card_name
	if source is SpaceData:
		return (source as SpaceData).space_name
	return "Unknown"
