extends Node

# Recomputes which Spaces are available based on the combined pips of all
# currently selected Minions and Plans.
#
# Rules:
# - Cards (Minions/Plans) are always selectable; availability is not tracked on them.
# - A Space is available when ALL of the following hold:
#     1. At least one Minion is selected.
#     2. At least one Plan is selected.
#     3. The union of all pips across all selected Minions and Plans satisfies
#        every requirement in at least one of the Space's requirement clauses.
# - A selected Space that is no longer satisfied is automatically deselected.
# - A selected Space is always marked available so it keeps its visual state.

func update() -> void:
	var tree := get_tree()
	var all_spaces:  Array = tree.get_nodes_in_group("SPACE")
	var sel_minions: Array = tree.get_nodes_in_group("MINION").filter(func(n): return n.selected)
	var sel_plans:   Array = tree.get_nodes_in_group("PLAN").filter(func(n): return n.selected)

	var can_select: bool = not sel_minions.is_empty() and not sel_plans.is_empty()
	var combined: Dictionary = _combine_pips(sel_minions + sel_plans)

	# Auto-deselect any selected space that is no longer satisfied.
	# Calling space.selected = false queues another Availability.update via
	# call_deferred, which will find nothing to deselect and terminate cleanly.
	for space in all_spaces:
		if space.selected and (not can_select or not _space_satisfied_by(space, combined)):
			space.selected = false

	for space in all_spaces:
		if space.selected:
			space.available = true
		elif not can_select:
			space.available = false
		else:
			space.available = _space_satisfied_by(space, combined)

# Builds a flat dictionary of which pip types are present across all given cards.
func _combine_pips(cards: Array) -> Dictionary:
	var p := {
		"vampire": false, "supernatural": false, "human": false,
		"battle": false, "hunt": false, "politics": false,
		"madness": false, "hideous": false, "sorcerous": false,
	}
	for card in cards:
		var d: CardData = card.card_data
		if d == null:
			continue
		if d.vampire:      p["vampire"]      = true
		if d.supernatural: p["supernatural"] = true
		if d.human:        p["human"]        = true
		if d.battle:       p["battle"]       = true
		if d.hunt:         p["hunt"]         = true
		if d.politics:     p["politics"]     = true
		if d.madness:      p["madness"]      = true
		if d.hideous:      p["hideous"]      = true
		if d.sorcerous:    p["sorcerous"]    = true
	return p

# Returns true if the combined pips satisfy at least one requirement clause.
func _space_satisfied_by(space: Space, pips: Dictionary) -> bool:
	if space.space_data == null:
		return false
	for clause in space.space_data.requirement_clauses:
		if clause != null and _clause_satisfied(clause, pips):
			return true
	return false

func _clause_satisfied(clause: SpaceRequirement, pips: Dictionary) -> bool:
	if clause.vampire      and not pips["vampire"]:      return false
	if clause.supernatural and not pips["supernatural"]: return false
	if clause.human        and not pips["human"]:        return false
	match clause.action:
		SpaceRequirement.ActionRequirement.BATTLE:
			if not pips["battle"]:   return false
		SpaceRequirement.ActionRequirement.HUNT:
			if not pips["hunt"]:     return false
		SpaceRequirement.ActionRequirement.POLITICS:
			if not pips["politics"]: return false
	match clause.aspect:
		SpaceRequirement.AspectRequirement.MADNESS:
			if not pips["madness"]:   return false
		SpaceRequirement.AspectRequirement.HIDEOUS:
			if not pips["hideous"]:   return false
		SpaceRequirement.AspectRequirement.SORCEROUS:
			if not pips["sorcerous"]: return false
	return true
