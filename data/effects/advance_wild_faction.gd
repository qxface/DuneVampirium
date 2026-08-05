class_name AdvanceWildFaction
extends Effect

## How many DISTINCT factions the player must choose to advance (each by 1 step).
## Two separate count=1 effects are NOT the same as one count=2 effect: distinctness
## is scoped to a single FactionPicker session, so two separate effects let the player
## pick the same faction twice, while one count=2 effect forces two different picks.
@export_range(1, 9) var count: int = 1

func get_icon() -> Texture2D:
	var path := "res://assets/icons/effects/wild_faction.png"
	if ResourceLoader.exists(path):
		return load(path)
	return null

func get_tags() -> String:
	if count >= 1 and count <= 9:
		return str(count)
	return ""

func trigger(game_context: Node, source: Resource = null) -> void:
	var player: PlayerState = game_context.get_current_player()
	var choices: Array = game_context.faction_tracks.keys()
	if choices.is_empty():
		push_warning("AdvanceWildFaction: no faction tracks registered")
		return
	FactionPicker.request_picks(choices, count, func(picked: Array) -> void:
		for faction_name: String in picked:
			game_context.advance_faction_track(player, faction_name, 1)
	)
