@tool
class_name SpaceRequirement
extends Resource

# One AND-clause in a Space's requirement list.
# Each category is optional (NONE = no requirement for that category).
# A Minion+Plan pair satisfies this clause when, for every non-NONE field,
# at least one of the two cards carries that pip.

enum ActionRequirement { NONE, POLITICS, HUNT, BATTLE }
enum AspectRequirement { NONE, MADNESS, HIDEOUS, SORCEROUS }

@export var origin: CardData.OriginType = CardData.OriginType.NONE
@export var action: ActionRequirement = ActionRequirement.NONE
@export var aspect: AspectRequirement = AspectRequirement.NONE

# True when this clause imposes no requirements at all.
func is_empty() -> bool:
	return origin == CardData.OriginType.NONE \
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
	match origin:
		CardData.OriginType.NONE:
			return true
		CardData.OriginType.VAMPIRE:
			return minion.vampire or plan.vampire
		CardData.OriginType.SUPERNATURAL:
			return minion.supernatural or plan.supernatural
		CardData.OriginType.HUMAN:
			return minion.human or plan.human
	return true

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

# Human-readable summary, e.g. "Vampire · Politics · Madness" or "Human"
func to_label() -> String:
	var parts: Array[String] = []
	if origin != CardData.OriginType.NONE:
		parts.append(CardData.OriginType.keys()[origin].capitalize())
	if action != ActionRequirement.NONE:
		parts.append(ActionRequirement.keys()[action].capitalize())
	if aspect != AspectRequirement.NONE:
		parts.append(AspectRequirement.keys()[aspect].capitalize())
	return " · ".join(parts) if not parts.is_empty() else "(empty)"
