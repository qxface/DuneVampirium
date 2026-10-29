class_name AdvanceWildFaction
extends Effect

## How many DISTINCT factions the player must choose to advance (each by 1 step).
## Two separate count=1 effects are NOT the same as one count=2 effect: distinctness
## is scoped to a single FactionPicker session, so two separate effects let the player
## pick the same faction twice, while one count=2 effect forces two different picks.
@export_range(1, 9) var count: int = 1

func get_icon(source: Resource = null) -> Texture2D:
	var path := "res://assets/icons/effects/wild_faction.png"
	if ResourceLoader.exists(path):
		return load(path)
	return null

func get_tags(source: Resource = null) -> String:
	if count >= 1 and count <= 9:
		return str(count)
	return ""

func trigger(game_context: Node, source: Resource = null) -> void:
	var player: PlayerState = game_context.get_current_player()
	var choices: Array = game_context.faction_tracks.keys()
	if choices.is_empty():
		ErrorTracker.report_error("AdvanceWildFaction: no faction tracks registered")
		return
	# The pick itself becomes its own Action Log entry/undo unit, separate from whatever
	# Place (or other Action) originally queued this effect — the snapshot is taken right
	# before the mutation actually happens (when the player finishes picking), not before
	# the picker opened, so it's undoable on its own regardless of how much else has
	# happened on-screen in between while the modal was up.
	FactionPicker.request_picks(choices, count, func(picked: Array) -> void:
		var names: Array = []
		for faction_name: String in picked:
			names.append(faction_name.capitalize())
		var description := "%s advanced %s" % [player.player_name, ", ".join(names)]
		var params := {"type": "advance_wild_faction", "player_index": game_context.current_player_index, "factions": picked}
		var pre := game_context.begin_undo_span()
		# Own independent error trace too, same reasoning as the Action Log entry below —
		# see globals/error_tracker.gd and the [[move-tracking-undo]] note on this effect.
		ErrorTracker.start_trace(pre, "advance_wild_faction", description, params)
		for faction_name: String in picked:
			game_context.advance_faction_track(player, faction_name, 1)
		game_context.commit_action_log(pre, "advance_wild_faction", description, params)
	)
