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
			return "✅ ALL REQUIREMENTS VALID"
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
# A Card HAS traits (an Origin, plus whichever Action/Aspect booleans are
# true). A Space instead REQUIRES traits: to make a move, a player sends one
# Minion and one Plan from their hand to a Space, and between that pair, every
# requirement flagged true below must be covered by at least one of the two
# cards. Any extra traits the cards have beyond what's required are
# irrelevant.
# ==============================================================================

@export_group("Origin Requirements")
@export var requires_vampire: bool = false
@export var requires_supernatural: bool = false
@export var requires_human: bool = false

@export_group("Action Requirements")
@export var requires_politics: bool = false
@export var requires_hunt: bool = false
@export var requires_battle: bool = false

@export_group("Aspect Requirements")
@export var requires_madness: bool = false
@export var requires_hideous: bool = false
@export var requires_sorcerous: bool = false

# Whether the given Minion + Plan pair, together, satisfy every requirement
# this Space has. For each requirement flag set true above, at least one of
# the two cards must have that corresponding trait true; which of the two
# cards covers it doesn't matter.
func is_satisfied_by(minion: CardData, plan: CardData) -> bool:
	if requires_vampire and !(minion.vampire or plan.vampire):
		return false
	if requires_supernatural and !(minion.supernatural or plan.supernatural):
		return false
	if requires_human and !(minion.human or plan.human):
		return false

	if requires_politics and !(minion.politics or plan.politics):
		return false
	if requires_hunt and !(minion.hunt or plan.hunt):
		return false
	if requires_battle and !(minion.battle or plan.battle):
		return false

	if requires_madness and !(minion.madness or plan.madness):
		return false
	if requires_hideous and !(minion.hideous or plan.hideous):
		return false
	if requires_sorcerous and !(minion.sorcerous or plan.sorcerous):
		return false

	return true

# ==============================================================================
# INTERNAL RESOURCE VALIDATION ENGINE
# ==============================================================================
func _get_data_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	var has_any_requirement: bool = requires_vampire or requires_supernatural or requires_human \
		or requires_politics or requires_hunt or requires_battle \
		or requires_madness or requires_hideous or requires_sorcerous

	if !has_any_requirement:
		warnings.append("Space has no requirements set - any pair of cards would satisfy it.")

	return warnings
