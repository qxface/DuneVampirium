class_name DrawCard
extends Effect

@export_range(1, 9) var amount: int = 1

func get_icon() -> Texture2D:
	return preload("res://assets/icons/effects/card_draw.png")

func get_tags() -> String:
	if amount <= 1 or amount > 9:
		return ""
	return str(amount)

func trigger(game_context: Node, source: Resource = null) -> void:
	var player: PlayerState = game_context.get_current_player()
	game_context.draw_plans(player, amount)
	print_debug("[%s] draws %d card%s  ←  %s" % [player.player_name, amount, "s" if amount != 1 else "", _source_name(source)])

static func _source_name(source: Resource) -> String:
	if source == null:
		return "unknown source"
	if source is CardData:
		return (source as CardData).card_name
	if source is SpaceData:
		return (source as SpaceData).space_name
	return source.resource_path.get_file().get_basename().replace("_", " ").capitalize()
