class_name AdvanceFactionTrack
extends Effect

## Which faction track to advance — must match the key in PlayerState.rapport
## and the faction_name on the target FactionTrackData resource.
@export var faction_name: String = ""

## How many steps to advance (usually 1).
@export var amount: int = 1

func get_icon() -> Texture2D:
	# Use the faction's clan icon as the effect icon (e.g. res://assets/icons/clans/primori.png).
	if faction_name.is_empty():
		return null
	var path := "res://assets/icons/clans/%s.png" % faction_name
	if ResourceLoader.exists(path):
		return load(path)
	return null

func get_tags() -> String:
	# Tag shows how many steps are gained; blank for the common case of 1
	# (a single-step advance is implied by the faction icon alone).
	if amount >= 2 and amount <= 9:
		return str(amount)
	return ""

func trigger(game_context: Node, source: Resource = null) -> void:
	if faction_name.is_empty():
		push_warning("AdvanceFactionTrack: faction_name is not set")
		return
	game_context.advance_faction_track(game_context.get_current_player(), faction_name, amount)
