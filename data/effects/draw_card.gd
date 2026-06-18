class_name DrawCard
extends Effect

@export_range(1, 9) var amount: int = 1

func trigger(game_context: Node) -> void:
	print_debug("Current Player draws %s cards!" % amount)
