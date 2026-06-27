class_name DrawCard
extends Effect

@export_range(1, 9) var amount: int = 1

func get_icon() -> Texture2D:
	return preload("res://assets/icons/effects/card_draw.png")

func trigger(game_context: Node, source: Resource = null) -> void:
	var player: PlayerState = game_context.get_current_player()
	var source_name: String = _source_name(source)
	print_debug("[%s] draws %d card%s  ←  %s" % [player.player_name, amount, "s" if amount != 1 else "", source_name])

static func _source_name(source: Resource) -> String:
	if source == null:
		return "unknown source"
	if source is CardData:
		return (source as CardData).card_name
	if source is SpaceData:
		return (source as SpaceData).space_name
	return source.resource_path.get_file().get_basename().replace("_", " ").capitalize()
