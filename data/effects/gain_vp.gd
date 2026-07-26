class_name GainVP
extends Effect

@export var amount: int = 1

func get_icon() -> Texture2D:
	return preload("res://assets/icons/resources/vp.png")

func get_tags() -> String:
	if amount >= 1 and amount <= 9:
		return str(amount)
	return ""

func trigger(game_context: Node, source: Resource = null) -> void:
	var player: PlayerState = game_context.get_current_player()
	player.vp += amount
	print_debug("[%s] gains %d VP  ←  %s" % [player.player_name, amount, _source_name(source)])

static func _source_name(source: Resource) -> String:
	if source == null:
		return "unknown"
	if source is CardData:
		return (source as CardData).card_name
	if source is SpaceData:
		return (source as SpaceData).space_name
	return source.resource_path.get_file().get_basename().replace("_", " ").capitalize()
