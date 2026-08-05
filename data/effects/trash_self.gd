class_name TrashSelf
extends Effect

## "Trash this card" — permanently removes the card carrying this effect from the
## game the moment it triggers (e.g. as an Agent effect, right after being placed).
## See GameState.trash_card() for the actual removal.

func get_icon() -> Texture2D:
	return preload("res://assets/icons/effects/card_trash.png")

func trigger(game_context: Node, source: Resource = null) -> void:
	if source == null or not (source is CardData):
		push_warning("TrashSelf: source is not a CardData")
		return
	game_context.trash_card(game_context.get_current_player(), source)
