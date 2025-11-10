class_name MinionCard
extends Card

@export var power: int = 0
@export var health: int = 0

func _init(
	card_name: String = "",
	power: int = 0,
	health: int = 0,
	acquire_func: Callable = Callable(),
	action_func: Callable = Callable(),
	reveal_func: Callable = Callable(),
	discard_func: Callable = Callable(),
	trash_func: Callable = Callable()
):
	super(acquire_func, action_func, reveal_func, discard_func, trash_func)
	self.card_name = card_name
	self.power = power
	self.health = health