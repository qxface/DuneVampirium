class_name AdvanceThisFaction
extends Effect

## Advances the faction track owned by the Space this effect is attached to — reads
## SpaceData.faction_name from `source` rather than carrying its own faction_name (unlike
## AdvanceFactionTrack, which is for a card-configured, fixed faction). Only valid as a
## Space's agent_effects reward; using it anywhere else (a Card's effects, a
## FactionMilestone's effects) is a no-op with a warning since there's no owning Space to
## read a faction from.
## Movement is step-by-step (see GameState.advance_faction_track()), so the player
## collects every milestone reward crossed or landed on, not just the final one.
@export_range(1, 9) var amount: int = 1

func get_icon(source: Resource = null) -> Texture2D:
	var faction_name := _faction_name_of(source)
	if faction_name.is_empty():
		return null
	var path := "res://assets/icons/clans/%s.png" % faction_name
	if ResourceLoader.exists(path):
		return load(path)
	return null

func get_tags(source: Resource = null) -> String:
	if amount >= 1 and amount <= 9:
		return str(amount)
	return ""

func trigger(game_context: Node, source: Resource = null) -> void:
	var faction_name := _faction_name_of(source)
	if faction_name.is_empty():
		ErrorTracker.report_error("AdvanceThisFaction: source is not a SpaceData with a faction_name set")
		return
	game_context.advance_faction_track(game_context.get_current_player(), faction_name, amount)

static func _faction_name_of(source: Resource) -> String:
	if source is SpaceData:
		return (source as SpaceData).faction_name
	return ""
