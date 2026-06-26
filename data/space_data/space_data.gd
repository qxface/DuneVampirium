@tool
class_name SpaceData
extends Resource

# ==============================================================================
# DYNAMIC WARNING NOTIFIER
# ==============================================================================
@export_group("Data Validation")
## If this says OK, your data is valid. Otherwise, read the warnings below!
@export var status_check: String = "OK":
	get:
		var warnings = _get_data_warnings()
		if warnings.is_empty():
			return "✅ ALL VALID"
		return "❌ ERROR: " + "; ".join(warnings)

var space_name: String = "New Space":
	get:
		var file_name: String = resource_path.get_file()
		var base_name: String = file_name.get_basename()
		var with_spaces: String = base_name.replacen("_", " ")
		return with_spaces.capitalize()

# ==============================================================================
# REQUIREMENTS
# ------------------------------------------------------------------------------
# A Space has zero or more SpaceRequirement clauses. Each clause is an AND of
# up to one pip per category (Origin, Action, Aspect). The clauses are OR'd:
# a Minion+Plan pair satisfies the Space when it satisfies ANY one clause.
#
# Examples:
#   [ {Supernatural, Politics} ]              → must have Supernatural AND Politics
#   [ {Vampire}, {Human, Battle} ]            → Vampire OR (Human AND Battle)
#   []                                        → open space, any pair qualifies
# ==============================================================================
@export_group("Requirements")
@export var requirement_clauses: Array[SpaceRequirement] = []

# Whether the given Minion+Plan pair satisfies this Space's requirements.
# An empty clause list means the space is open — any pair qualifies.
func is_satisfied_by(minion: CardData, plan: CardData) -> bool:
	if requirement_clauses.is_empty():
		return true
	for clause in requirement_clauses:
		if clause != null and clause.is_satisfied_by(minion, plan):
			return true
	return false

# ==============================================================================
# AGENT ACTION
# ==============================================================================
@export_group("Agent Action")
@export var agent_cost: GameEnums.CostType = GameEnums.CostType.NONE:
	set(v): agent_cost = v; notify_property_list_changed()
@export var agent_cost_amount: int = 0:
	set(v): agent_cost_amount = max(0, v); notify_property_list_changed()
@export var agent_requirement: GameEnums.RequirementType = GameEnums.RequirementType.NONE:
	set(v): agent_requirement = v; notify_property_list_changed()
@export var agent_requirement_amount: int = 0:
	set(v): agent_requirement_amount = max(0, v); notify_property_list_changed()
@export var agent_effects: Array[Effect] = []:
	set(v): agent_effects = v; notify_property_list_changed()

var agent_action: bool:
	get: return not agent_effects.is_empty()

# ==============================================================================
# INTERNAL RESOURCE VALIDATION ENGINE
# ==============================================================================
func _get_data_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if requirement_clauses.is_empty():
		warnings.append("No requirement clauses — any pair of cards satisfies this space.")
	else:
		for i in requirement_clauses.size():
			var clause: SpaceRequirement = requirement_clauses[i]
			if clause == null:
				warnings.append("Clause %d is null." % (i + 1))
			elif clause.is_empty():
				warnings.append("Clause %d has no requirements set — it will always pass." % (i + 1))

	_check_action_warnings(warnings, "Agent", agent_effects, agent_cost, agent_cost_amount, agent_requirement, agent_requirement_amount)

	return warnings

func _check_action_warnings(warnings: PackedStringArray, action_name: String, effects: Array, cost_type: int, cost_amount: int, req_type: int, req_amount: int) -> void:
	var is_cost_none: bool = (cost_type == GameEnums.CostType.NONE)
	var is_req_none: bool  = (req_type  == GameEnums.RequirementType.NONE)
	var has_effects: bool  = not effects.is_empty()

	if not has_effects:
		if not is_cost_none or cost_amount > 0:
			warnings.append("[%s] Has cost configuration but missing Effects" % action_name)
		if not is_req_none or req_amount > 0:
			warnings.append("[%s] Has requirement configuration but missing Effects" % action_name)
		return

	if not is_cost_none and cost_amount == 0:
		warnings.append("[%s] Cost type is set, but amount is 0" % action_name)
	elif is_cost_none and cost_amount > 0:
		warnings.append("[%s] Cost amount is > 0, but type is NONE" % action_name)

	if not is_req_none and req_amount == 0:
		warnings.append("[%s] Requirement type is set, but amount is 0" % action_name)
	elif is_req_none and req_amount > 0:
		warnings.append("[%s] Requirement amount is > 0, but type is NONE" % action_name)
