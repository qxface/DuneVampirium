@tool
class_name SpaceRequirement
extends Resource

# One AND-clause in a Space's requirement list.
# Each category is optional (false = no requirement for that category).
# A set of cards (≥1 Minion + ≥1 Plan) satisfies this clause when the union
# of all their pips covers every non-false field.
#
# cost_type/cost_amount and requirement_type/requirement_amount are the toll
# to send a Minion/Plan set to the Space via this clause: requirement is a
# minimum resource/Rapport threshold the player must hold (not spent), cost
# is spent as part of the Place action. Both are resolved against the acting
# player in GameState (this Resource stays player-agnostic).

enum ActionRequirement { NONE, NEGOTIATE, HUNT, FIGHT }
enum AspectRequirement { NONE, INSANE, HIDEOUS, ARCANE }

@export_group("Data Validation")
## If this says OK, your data is valid. Otherwise, read the warnings below!
@export var status_check: String = "OK":
	get:
		var warnings = _get_data_warnings()
		if warnings.is_empty():
			return "✅ ALL VALID"
		return "❌ ERROR: " + "; ".join(warnings)

@export_group("Origin")
@export var vampire: bool = false
@export var supernatural: bool = false
@export var human: bool = false

@export_group("Other")
@export var action: ActionRequirement = ActionRequirement.NONE
@export var aspect: AspectRequirement = AspectRequirement.NONE

@export_group("Cost")
@export var cost_type: GameEnums.CostType = GameEnums.CostType.NONE:
	set(v): cost_type = v; notify_property_list_changed()
@export var cost_amount: int = 0:
	set(v): cost_amount = max(0, v); notify_property_list_changed()

@export_group("Resource Requirement")
@export var requirement_type: GameEnums.RequirementType = GameEnums.RequirementType.NONE:
	set(v): requirement_type = v; notify_property_list_changed()
@export var requirement_amount: int = 0:
	set(v): requirement_amount = max(0, v); notify_property_list_changed()

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

func _get_data_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	var is_cost_none: bool = (cost_type == GameEnums.CostType.NONE)
	var is_req_none: bool  = (requirement_type == GameEnums.RequirementType.NONE)

	if not is_cost_none and cost_amount == 0:
		warnings.append("Cost type is set, but amount is 0")
	elif is_cost_none and cost_amount > 0:
		warnings.append("Cost amount is > 0, but type is NONE")

	if not is_req_none and requirement_amount == 0:
		warnings.append("Requirement type is set, but amount is 0")
	elif is_req_none and requirement_amount > 0:
		warnings.append("Requirement amount is > 0, but type is NONE")

	return warnings

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
