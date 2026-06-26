class_name DrawCard
extends Effect

@export_range(1, 9) var amount: int = 1

func get_icon() -> Texture2D:
	return preload("res://assets/icons/effects/card_draw.png")

func trigger(game_context: Node) -> void:
	print_debug("Current Player draws %s cards!" % amount)
