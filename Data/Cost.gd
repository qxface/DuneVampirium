class_name Cost
extends ActivationComponent

enum CostType { BLOOD, MONEY, SECRETS, DISCARD_PLAN, TRASH_PLAN }

@export var cost_type: CostType:
	set(value):
		cost_type = value
		_update_icon_and_description(cost_type)
@export var amount: int = 0  # For resource costs

func _init():
	component_type = ComponentType.COST

func can_pay(player: Player) -> bool:
	if not player:
		return false
	
	match cost_type:
		CostType.BLOOD:
			return player.blood >= amount
		CostType.MONEY:
			return player.money >= amount
		CostType.SECRETS:
			return player.secrets >= amount
		CostType.DISCARD_PLAN, CostType.TRASH_PLAN:
			# These require a card context, handled differently
			return true  # Will be handled by card logic
	return false

func pay(player: Player) -> bool:
	if not can_pay(player):
		return false
	
	match cost_type:
		CostType.BLOOD:
			player.blood -= amount
		CostType.MONEY:
			player.money -= amount
		CostType.SECRETS:
			player.secrets -= amount
		# DISCARD_PLAN and TRASH_PLAN handled by card logic
	return true

func _update_icon_and_description(new_cost_type):
	match new_cost_type:
		CostType.BLOOD:
			icon_texture_path = "res://assets/icons/resources/blood.png"
			description = "Pay %d blood" % amount
			tag = str(amount)  # Shows as "3" for paying 3 blood
		CostType.MONEY:
			icon_texture_path = "res://assets/icons/resources/money.png"
			description = "Pay %d money" % amount
			tag = str(amount)
		CostType.SECRETS:
			icon_texture_path = "res://assets/icons/resources/secret.png"
			description = "Pay %d secrets" % amount
			tag = str(amount)
		CostType.DISCARD_PLAN:
			icon_texture_path = "res://assets/piles/discard_pile.png"
			description = "Discard a plan"
			tag = ""
		CostType.TRASH_PLAN:
			icon_texture_path = "res://assets/piles/discard_pile.png"  # Need trash icon
			description = "Trash a plan"
			tag = ""
