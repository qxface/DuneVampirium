@tool
class_name SpaceRequirement
extends Resource

# One AND-clause in a Space's requirement list.
# Each category is optional (false = no requirement for that category).
# A set of cards (≥1 Minion + ≥1 Plan) satisfies this clause when the union
# of all their pips covers every non-false field.

enum ActionRequirement { NONE, NEGOTIATE, HUNT, FIGHT }
enum AspectRequirement { NONE, INSANE, HIDEOUS, ARCANE }

@export_group("Origin")
@export var vampire: bool = false
@export var supernatural: bool = false
@export var human: bool = false

@export_group("Other")
@export var action: ActionRequirement = ActionRequirement.NONE
@export var aspect: AspectRequirement = AspectRequirement.NONE

# True when this clause imposes no requirements at all.
func is_empty() -> bool:
	return not vampire and not supernatural and not human \
		and action == ActionRequirement.NONE \
		and aspect == AspectRequirement.NONE

# Whether the union of pips across all cards in minions + plans satisfies this clause.
func is_satisfied_by(minions: Array, plans: Array) -> bool:
	var pips := _union_pips(minions + plans)
	if vampire      and not pips["vampire"]:      return false
	if supernatural and not pips["supernatural"]: return false
	if human        and not pips["human"]:        return false
	match action:
		ActionRequirement.NEGOTIATE:
			if not pips["negotiate"]: return false
		ActionRequirement.HUNT:
			if not pips["hunt"]:      return false
		ActionRequirement.FIGHT:
			if not pips["fight"]:     return false
	match aspect:
		AspectRequirement.INSANE:
			if not pips["insane"]:   return false
		AspectRequirement.HIDEOUS:
			if not pips["hideous"]:  return false
		AspectRequirement.ARCANE:
			if not pips["arcane"]:   return false
	return true

func _union_pips(cards: Array) -> Dictionary:
	var p := {
		"vampire": false, "supernatural": false, "human": false,
		"fight": false, "hunt": false, "negotiate": false,
		"insane": false, "hideous": false, "arcane": false,
	}
	for card: CardData in cards:
		if card == null: continue
		if card.vampire:      p["vampire"]      = true
		if card.supernatural: p["supernatural"] = true
		if card.human:        p["human"]        = true
		if card.fight:        p["fight"]        = true
		if card.hunt:         p["hunt"]         = true
		if card.negotiate:    p["negotiate"]    = true
		if card.insane:       p["insane"]       = true
		if card.hideous:      p["hideous"]      = true
		if card.arcane:       p["arcane"]       = true
	return p

# Human-readable summary, e.g. "Vampire · Supernatural · Negotiate"
func to_label() -> String:
	var parts: Array[String] = []
	if vampire:
		parts.append("Vampire")
	if supernatural:
		parts.append("Supernatural")
	if human:
		parts.append("Human")
	if action != ActionRequirement.NONE:
		parts.append(ActionRequirement.keys()[action].capitalize())
	if aspect != AspectRequirement.NONE:
		parts.append(AspectRequirement.keys()[aspect].capitalize())
	return " · ".join(parts) if not parts.is_empty() else "(empty)"
