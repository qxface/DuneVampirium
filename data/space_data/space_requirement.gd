@tool
class_name SpaceRequirement
extends Resource

# One AND-clause in a Space's requirement list.
# Each category is optional (false = no requirement for that category).
# A Minion+Plan pair satisfies this clause when, for every non-false field,
# at least one of the two cards carries that pip.

enum ActionRequirement { NONE, POLITICS, HUNT, BATTLE }
enum AspectRequirement { NONE, MADNESS, HIDEOUS, SORCEROUS }

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

# Whether the given Minion+Plan pair satisfies every pip required by this clause.
func is_satisfied_by(minion: CardData, plan: CardData) -> bool:
	if not _check_origin(minion, plan):
		return false
	if not _check_action(minion, plan):
		return false
	if not _check_aspect(minion, plan):
		return false
	return true

func _check_origin(minion: CardData, plan: CardData) -> bool:
	if not vampire and not supernatural and not human:
		return true
	if vampire and (minion.vampire or plan.vampire):
		return true
	if supernatural and (minion.supernatural or plan.supernatural):
		return true
	if human and (minion.human or plan.human):
		return true
	return false

func _check_action(minion: CardData, plan: CardData) -> bool:
	match action:
		ActionRequirement.NONE:
			return true
		ActionRequirement.POLITICS:
			return minion.politics or plan.politics
		ActionRequirement.HUNT:
			return minion.hunt or plan.hunt
		ActionRequirement.BATTLE:
			return minion.battle or plan.battle
	return true

func _check_aspect(minion: CardData, plan: CardData) -> bool:
	match aspect:
		AspectRequirement.NONE:
			return true
		AspectRequirement.MADNESS:
			return minion.madness or plan.madness
		AspectRequirement.HIDEOUS:
			return minion.hideous or plan.hideous
		AspectRequirement.SORCEROUS:
			return minion.sorcerous or plan.sorcerous
	return true

# Human-readable summary, e.g. "Vampire · Supernatural · Politics"
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
