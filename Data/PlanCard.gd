class_name PlanCard
extends Card

@export var influence_cost: int = 0

func _init(
	card_name: String = "",
	influence_cost: int = 0,
	acquire_func: Callable = Callable(),
	action_func: Callable = Callable(),
	reveal_func: Callable = Callable(),
	discard_func: Callable = Callable(),
	trash_func: Callable = Callable()
):
	super(acquire_func, action_func, reveal_func, discard_func, trash_func)
	self.card_name = card_name
	self.influence_cost = influence_cost