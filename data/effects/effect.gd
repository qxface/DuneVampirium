class_name Effect
extends Resource

# source is the CardData/SpaceData this effect is currently being displayed on (the same
# value that will be passed to trigger()) — optional since most effects don't need it,
# but some (e.g. AdvanceThisFaction) need to know their owner to pick the right icon.
func get_icon(source: Resource = null) -> Texture2D:
	return null

func get_tags(source: Resource = null) -> String:
	return ""

# Whether this effect reveals information (or otherwise commits something) that makes
# it unfair to undo normally — e.g. drawing a card. False by default; override per
# Effect subclass. A GameState-wide "Gentleman's Undo" setting can still allow undoing
# a binding effect if the table agrees to it.
func is_binding() -> bool:
	return false

func trigger(game_context: Node, source: Resource = null) -> void:
	pass
