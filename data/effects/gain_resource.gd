class_name GainResource
extends Effect

enum GainType { MONEY, BLOOD, SECRET }

@export var type: GainType = GainType.MONEY
@export var amount: int = 1

func get_icon() -> Texture2D:
	match type:
		GainType.MONEY:  return preload("res://assets/icons/resources/money.png")
		GainType.BLOOD:  return preload("res://assets/icons/resources/blood.png")
		GainType.SECRET: return preload("res://assets/icons/resources/secret.png")
	return null

func trigger(game_context: Node) -> void:
	var player = game_context.get_current_player()
	match type:
		GainType.MONEY:  player.money += amount
		GainType.BLOOD:  player.blood += amount
		GainType.SECRET: player.secrets += amount
	print("Triggered: Gained ", amount, " of ", GainType.keys()[type])
