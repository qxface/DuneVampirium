@tool
class_name CardData
extends Resource

enum CardType {
	PLAN,
	MINION
}


# ==============================================================================
# DYNAMIC WARNING NOTIFIER
# ==============================================================================
@export_group("Data Validation")
## If this says OK, your data is valid. Otherwise, read the warnings below!
@export var status_check: String = "OK":
	get:
		var warnings = _get_data_warnings()
		if warnings.is_empty():
			return "✅ ALL ACTIONS VALID"
		return "❌ ERROR: " + "; ".join(warnings)

var card_name: String = "New Card":
	get:
		var file_name: String = resource_path.get_file()
		var base_name: String = file_name.get_basename()
		var with_spaces: String = base_name.replacen("_", " ")
		return with_spaces.capitalize()

@export var card_type: CardType = CardType.PLAN:
	set(value):
		card_type = value
		notify_property_list_changed()

@export_group("Origin")
@export var vampire: bool = false
@export var supernatural: bool = false
@export var human: bool = false

@export_group("Actions")
@export var politics: bool = false
@export var hunt: bool = false
@export var battle: bool = false

@export_group("Aspects")
@export var madness: bool = false
@export var hideous: bool = false
@export var sorcerous: bool = false
















# ==============================================================================
# LIFECYCLE ACTIONS
# ==============================================================================

# --- ACQUIRE ACTION ---
@export_group("Acquire Action")
@export var acquire_cost: GameEnums.CostType = GameEnums.CostType.NONE:
	set(v): acquire_cost = v; notify_property_list_changed()
@export var acquire_cost_amount: int = 0:
	set(v): acquire_cost_amount = max(0, v); notify_property_list_changed()
@export var acquire_requirement: GameEnums.RequirementType = GameEnums.RequirementType.NONE:
	set(v): acquire_requirement = v; notify_property_list_changed()
@export var acquire_requirement_amount: int = 0:
	set(v): acquire_requirement_amount = max(0, v); notify_property_list_changed()
@export var acquire_effects: Array[Effect] = []:
	set(v): acquire_effects = v; notify_property_list_changed()

var acquire_action: bool:
	get: return !acquire_effects.is_empty()

# --- AGENT ACTION ---
@export_group("Agent Action")
@export var agent_cost: GameEnums.CostType = GameEnums.CostType.NONE:
	set(v): agent_cost = v; notify_property_list_changed()
@export var agent_cost_amount: int = 0:
	set(v): agent_cost_amount = max(0, v); notify_property_list_changed()
@export var agent_requirement: GameEnums.RequirementType = GameEnums.RequirementType.NONE:
	set(v): agent_requirement = v; notify_property_list_changed()
@export_group("Agent Action") # Repeating group hint ensures order stays clean
@export var agent_requirement_amount: int = 0:
	set(v): agent_requirement_amount = max(0, v); notify_property_list_changed()
@export var agent_effects: Array[Effect] = []:
	set(v): agent_effects = v; notify_property_list_changed()

var agent_action: bool:
	get: return !agent_effects.is_empty()

# --- REVEAL ACTION ---
@export_group("Reveal Action")
@export var reveal_cost: GameEnums.CostType = GameEnums.CostType.NONE:
	set(v): reveal_cost = v; notify_property_list_changed()
@export var reveal_cost_amount: int = 0:
	set(v): reveal_cost_amount = max(0, v); notify_property_list_changed()
@export var reveal_requirement: GameEnums.RequirementType = GameEnums.RequirementType.NONE:
	set(v): reveal_requirement = v; notify_property_list_changed()
@export var reveal_requirement_amount: int = 0:
	set(v): reveal_requirement_amount = max(0, v); notify_property_list_changed()
@export var reveal_effects: Array[Effect] = []:
	set(v): reveal_effects = v; notify_property_list_changed()

var reveal_action: bool:
	get: return !reveal_effects.is_empty()

# --- DISCARD ACTION ---
@export_group("Discard Action")
@export var discard_cost: GameEnums.CostType = GameEnums.CostType.NONE:
	set(v): discard_cost = v; notify_property_list_changed()
@export var discard_cost_amount: int = 0:
	set(v): discard_cost_amount = max(0, v); notify_property_list_changed()
@export var discard_requirement: GameEnums.RequirementType = GameEnums.RequirementType.NONE:
	set(v): discard_requirement = v; notify_property_list_changed()
@export var discard_requirement_amount: int = 0:
	set(v): discard_requirement_amount = max(0, v); notify_property_list_changed()
@export var discard_effects: Array[Effect] = []:
	set(v): discard_effects = v; notify_property_list_changed()

var discard_action: bool:
	get: return !discard_effects.is_empty()

# --- TRASH ACTION ---
@export_group("Trash Action")
@export var trash_cost: GameEnums.CostType = GameEnums.CostType.NONE:
	set(v): trash_cost = v; notify_property_list_changed()
@export var trash_cost_amount: int = 0:
	set(v): trash_cost_amount = max(0, v); notify_property_list_changed()
@export var trash_requirement: GameEnums.RequirementType = GameEnums.RequirementType.NONE:
	set(v): trash_requirement = v; notify_property_list_changed()
@export var trash_requirement_amount: int = 0:
	set(v): trash_requirement_amount = max(0, v); notify_property_list_changed()
@export var trash_effects: Array[Effect] = []:
	set(v): trash_effects = v; notify_property_list_changed()

var trash_action: bool:
	get: return !trash_effects.is_empty()


# ==============================================================================
# INTERNAL RESOURCE VALIDATION ENGINE
# ==============================================================================

func _get_data_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()

	if card_type == CardType.MINION and not vampire and not supernatural and not human:
		warnings.append("Minion must have at least one Origin (Vampire, Supernatural, or Human)")

	_check_action_warnings(warnings, "Acquire", acquire_effects, acquire_cost, acquire_cost_amount, acquire_requirement, acquire_requirement_amount)
	_check_action_warnings(warnings, "Agent", agent_effects, agent_cost, agent_cost_amount, agent_requirement, agent_requirement_amount)
	_check_action_warnings(warnings, "Reveal", reveal_effects, reveal_cost, reveal_cost_amount, reveal_requirement, reveal_requirement_amount)
	_check_action_warnings(warnings, "Discard", discard_effects, discard_cost, discard_cost_amount, discard_requirement, discard_requirement_amount)
	_check_action_warnings(warnings, "Trash", trash_effects, trash_cost, trash_cost_amount, trash_requirement, trash_requirement_amount)

	return warnings

func _check_action_warnings(warnings: PackedStringArray, action_name: String, effects: Array, cost_type: int, cost_amount: int, req_type: int, req_amount: int) -> void:
	# Convert enums to strings using the values you defined above.
	# We assume the last option in your enum definitions is 'NONE'
	var is_cost_none: bool = (cost_type == GameEnums.CostType.NONE)
	var is_req_none: bool = (req_type == GameEnums.RequirementType.NONE)
	
	var has_effects = !effects.is_empty()

	if !has_effects:
		if !is_cost_none or cost_amount > 0:
			warnings.append("[%s] Has cost configuration but missing Effects" % action_name)
		if !is_req_none or req_amount > 0:
			warnings.append("[%s] Has requirement configuration but missing Effects" % action_name)
		return
	
	if !is_cost_none and cost_amount == 0:
		warnings.append("[%s] Cost type is set, but amount is 0" % action_name)
	elif is_cost_none and cost_amount > 0:
		warnings.append("[%s] Cost amount is > 0, but type is NONE" % action_name)
		
	if !is_req_none and req_amount == 0:
		warnings.append("[%s] Requirement type is set, but amount is 0" % action_name)
	elif is_req_none and req_amount > 0:
		warnings.append("[%s] Requirement amount is > 0, but type is NONE" % action_name)
	
	var has_cost = cost_type != GameEnums.CostType.NONE
	var has_req = req_type != GameEnums.RequirementType.NONE

	# Error State 1: Trying to set up costs/requirements on an action type that has no effects assigned
	if !has_effects:
		if has_cost or cost_amount > 0:
			warnings.append("%s Action: Cannot assign costs or amounts because the Effects array is empty." % action_name)
		if has_req or req_amount > 0:
			warnings.append("%s Action: Cannot assign requirements or amounts because the Effects array is empty." % action_name)
		return # No need to check other constraints if there are no effects
		
	# Error State 2: Missing active configuration details when an action *is* active
	if has_cost and cost_amount == 0:
		warnings.append("%s Action: A Cost Type is set, but the Cost Amount is 0." % action_name)
	elif !has_cost and cost_amount > 0:
		warnings.append("%s Action: Cost Amount is greater than 0, but the Cost Type is set to NONE." % action_name)
		
	if has_req and req_amount == 0:
		warnings.append("%s Action: A Requirement Type is set, but the Requirement Amount is 0." % action_name)
	elif !has_req and req_amount > 0:
		warnings.append("%s Action: Requirement Amount is greater than 0, but the Requirement Type is set to NONE." % action_name)
