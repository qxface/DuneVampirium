extends Node

signal updated

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

	updated.emit()

# Builds a flat dictionary of which pip types are present across all given cards.
func _combine_pips(cards: Array) -> Dictionary:
	var p := {
		"vampire": false, "supernatural": false, "human": false,
		"fight": false, "hunt": false, "negotiate": false,
		"insane": false, "hideous": false, "arcane": false,
	}
	for card in cards:
		var d: CardData = card.card_data
		if d == null:
			continue
		if d.vampire:      p["vampire"]      = true
		if d.supernatural: p["supernatural"] = true
		if d.human:        p["human"]        = true
		if d.fight:        p["fight"]        = true
		if d.hunt:         p["hunt"]         = true
		if d.negotiate:    p["negotiate"]    = true
		if d.insane:       p["insane"]       = true
		if d.hideous:      p["hideous"]      = true
		if d.arcane:       p["arcane"]       = true
	return p

# Returns true if the combined pips satisfy at least one requirement clause.
func _space_satisfied_by(space: Space, pips: Dictionary) -> bool:
	if space.space_data == null or space.is_occupied:
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
		SpaceRequirement.ActionRequirement.FIGHT:
			if not pips["fight"]:     return false
		SpaceRequirement.ActionRequirement.HUNT:
			if not pips["hunt"]:      return false
		SpaceRequirement.ActionRequirement.NEGOTIATE:
			if not pips["negotiate"]: return false
	match clause.aspect:
		SpaceRequirement.AspectRequirement.INSANE:
			if not pips["insane"]:   return false
		SpaceRequirement.AspectRequirement.HIDEOUS:
			if not pips["hideous"]:  return false
		SpaceRequirement.AspectRequirement.ARCANE:
			if not pips["arcane"]:  return false
	return true
