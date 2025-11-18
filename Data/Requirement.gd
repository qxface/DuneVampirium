# New file: res://Data/Requirement.gd
class_name Requirement
extends ActivationComponent

enum RequirementType { BLOOD, MONEY, SECRETS }

@export var requirement_type: RequirementType:
	set(value):
		requirement_type = value
		_update_icon_and_description(requirement_type)
@export var amount: int = 0  # For resource costs
@export var comparison: String = ""  # e.g., "3+", "6-", "5"

func _init():
	component_type = ComponentType.REQUIREMENT

func is_met(player: Player) -> bool:
	if not player:
		return false
	
	var value: int = 0
	match requirement_type:
		RequirementType.BLOOD:
			value = player.blood
		RequirementType.MONEY:
			value = player.money
		RequirementType.SECRETS:
			value = player.secrets
	
	return _evaluate_comparison(value, comparison)

func _evaluate_comparison(value: int, comp: String) -> bool:
	if comp.ends_with("+"):
		var threshold = comp.trim_suffix("+").to_int()
		return value >= threshold
	elif comp.ends_with("-"):
		var threshold = comp.trim_suffix("-").to_int()
		return value <= threshold
	else:
		var threshold = comp.to_int()
		return value == threshold

func _update_icon_and_description(new_requirement_type):
	match new_requirement_type:
		RequirementType.BLOOD:
			icon_texture_path = "res://assets/icons/resources/blood.png"
			description = "Blood requirement"
		RequirementType.MONEY:
			icon_texture_path = "res://assets/icons/resources/money.png"
			description = "Money requirement"
		RequirementType.SECRETS:
			icon_texture_path = "res://assets/icons/resources/secret.png"
			description = "Secrets requirement"
