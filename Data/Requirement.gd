# res://Data/Requirement.gd
# New file: res://Data/Requirement.gd
class_name Requirement
extends ActivationComponent

@export var icon_type: IconTypes.Type = IconTypes.Type.BLOOD
@export var amount: int = 0
@export var comparison: String = "+"  # "+" for minimum, "-" for maximum

func _init():
	component_type = ComponentType.REQUIREMENT
	_update_icon_and_description()

func is_met(player: Player) -> bool:
	if not player:
		return false
	
	var player_amount: int = 0
	match icon_type:
		IconTypes.Type.BLOOD:
			player_amount = player.blood
		IconTypes.Type.MONEY:
			player_amount = player.money
		IconTypes.Type.SECRETS:
			player_amount = player.secrets
	
	if comparison == "+":  # Minimum requirement
		return player_amount >= amount
	elif comparison == "-":  # Maximum requirement
		return player_amount <= amount
	else:  # Exact requirement
		return player_amount == amount

func _update_icon_and_description():
	icon_texture_path = IconTypes.get_texture_path(icon_type)
	
	match icon_type:
		IconTypes.Type.BLOOD:
			description = "%d%s blood required" % [amount, comparison]
			tag = str(amount) + comparison
		IconTypes.Type.MONEY:
			description = "%d%s money required" % [amount, comparison]
			tag = str(amount) + comparison
		IconTypes.Type.SECRETS:
			description = "%d%s secrets required" % [amount, comparison]
			tag = str(amount) + comparison
