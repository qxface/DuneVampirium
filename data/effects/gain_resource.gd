class_name GainResource
extends Effect

# Reusing your existing RequirementType/CostType conceptually
enum GainType { MONEY, BLOOD, SECRETS }

@export var type: GainType = GainType.MONEY
@export var amount: int = 1

func trigger(game_context: Node) -> void:
	var player = game_context.get_current_player()
	match type:
		GainType.MONEY: player.money += amount
		GainType.BLOOD: player.blood += amount
		GainType.SECRETS: player.secrets += amount
	print("Triggered: Gained ", amount, " of ", GainType.keys()[type])
