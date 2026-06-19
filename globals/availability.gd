extends Node

# Recomputes which Spaces, Minions, and Plans are available based on the
# current selection state. Call update() at game start and after any
# selection change.
#
# When nothing is selected every node is a candidate. When items of a type
# are selected, only the selected ones are candidates for that type.
# A Space is available when at least one (minion, plan) candidate pair
# satisfies its requirements. A Minion/Plan is available when it can pair
# with at least one candidate of the other card type to satisfy at least one
# candidate Space.
#
# Selected items are always marked available so they keep their visual state
# and so the Card invariant "selected implies available" is not violated.

func update() -> void:
	var tree := get_tree()
	var all_spaces:  Array = tree.get_nodes_in_group("SPACE")
	var all_minions: Array = tree.get_nodes_in_group("MINION")
	var all_plans:   Array = tree.get_nodes_in_group("PLAN")

	var sel_spaces:  Array = all_spaces.filter(func(n): return n.selected)
	var sel_minions: Array = all_minions.filter(func(n): return n.selected)
	var sel_plans:   Array = all_plans.filter(func(n): return n.selected)

	var cand_spaces:  Array = sel_spaces  if not sel_spaces.is_empty()  else all_spaces
	var cand_minions: Array = sel_minions if not sel_minions.is_empty() else all_minions
	var cand_plans:   Array = sel_plans   if not sel_plans.is_empty()   else all_plans

	for space in all_spaces:
		if space.selected:
			space.available = true
			continue
		if space not in cand_spaces:
			space.available = false
			continue
		space.available = _space_has_valid_pair(space, cand_minions, cand_plans)

	for minion in all_minions:
		minion.available = _card_can_contribute(minion, cand_spaces, cand_plans, true)

	for plan in all_plans:
		plan.available = _card_can_contribute(plan, cand_spaces, cand_minions, false)

# Returns true when any (minion, plan) pair from the candidate pools satisfies
# this space.
func _space_has_valid_pair(space: Space, minions: Array, plans: Array) -> bool:
	if space.space_data == null:
		return false
	for minion in minions:
		if minion.card_data == null:
			continue
		for plan in plans:
			if plan.card_data == null:
				continue
			if space.space_data.is_satisfied_by(minion.card_data, plan.card_data):
				return true
	return false

# Returns true when this card (minion or plan) can pair with at least one
# partner from the partner pool to satisfy at least one candidate space.
# is_minion controls the argument order passed to is_satisfied_by.
func _card_can_contribute(card: Card, spaces: Array, partners: Array, is_minion: bool) -> bool:
	if card.card_data == null:
		return false
	for space in spaces:
		if space.space_data == null:
			continue
		for partner in partners:
			if partner.card_data == null:
				continue
			var satisfied: bool
			if is_minion:
				satisfied = space.space_data.is_satisfied_by(card.card_data, partner.card_data)
			else:
				satisfied = space.space_data.is_satisfied_by(partner.card_data, card.card_data)
			if satisfied:
				return true
	return false
