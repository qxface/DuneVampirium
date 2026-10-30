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

# --- Action-token cost / repeat limit (CLAUDE.md 2026-10-20 decisions) ---
# A second, independent cost dimension from cost_type/cost_amount above (which is a
# resource cost — Money/Blood/Secret/Rapport). Only Reveal-phase Minion items set these
# today (see GameState.build_reveal_pending_actions()); every other pending item leaves
# them at their defaults, which are no-ops (0 cost, fires at most once).
var action_token_cost: int = 0
var max_uses: int = 1       # -1 = unlimited (bounded only by affordability each time)
var uses_so_far: int = 0    # incremented by GameState.try_trigger_pending() on each success

func has_cost() -> bool:
	return cost_type != GameEnums.CostType.NONE and cost_amount > 0

func has_action_token_cost() -> bool:
	return action_token_cost > 0

func can_use_again() -> bool:
	return max_uses == -1 or uses_so_far < max_uses

func is_minion_sourced() -> bool:
	return source is CardData and (source as CardData).card_type == CardData.CardType.MINION

func source_name() -> String:
	if source is CardData:
		return (source as CardData).card_name
	if source is SpaceData:
		return (source as SpaceData).space_name
	return "Unknown"
