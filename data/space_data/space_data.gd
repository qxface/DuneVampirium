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
# INTERNAL RESOURCE VALIDATION ENGINE
# ==============================================================================
func _get_data_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if requirement_clauses.is_empty():
		warnings.append("No requirement clauses — any pair of cards satisfies this space.")
		return warnings

	for i in requirement_clauses.size():
		var clause: SpaceRequirement = requirement_clauses[i]
		if clause == null:
			warnings.append("Clause %d is null." % (i + 1))
		elif clause.is_empty():
			warnings.append("Clause %d has no requirements set — it will always pass." % (i + 1))

	return warnings
