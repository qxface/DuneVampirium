extends Node

func chance(odds: int) -> bool:
	if odds <= 0:
		return false
	elif odds >= 100:
		return true
	else:
		return (randf() < (odds / 100))
