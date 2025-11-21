# res://Data/Cost.gd
class_name Cost
extends ActivationComponent

@export var icon_type: IconTypes.Type = IconTypes.Type.BLOOD
@export var amount: int = 0

func _init():
	component_type = ComponentType.COST
	_update_icon_and_description()

func can_pay(player: Player) -> bool:
	if not player:
		return false
	
	match icon_type:
		IconTypes.Type.BLOOD:
			return player.blood >= amount
		IconTypes.Type.MONEY:
			return player.money >= amount
		IconTypes.Type.SECRETS:
			return player.secrets >= amount
		IconTypes.Type.PLAN:
			return player.hand.size() >= amount  # Player must have enough plans to discard
		IconTypes.Type.PLAN_TRASH:
			return player.hand.size() >= amount  # Player must have enough plans to trash
	return false

func pay(player: Player) -> bool:
	if not can_pay(player):
		return false
	
	match icon_type:
		IconTypes.Type.BLOOD:
			player.blood -= amount
		IconTypes.Type.MONEY:
			player.money -= amount
		IconTypes.Type.SECRETS:
			player.secrets -= amount
		IconTypes.Type.PLAN:
			# Discard amount plans from hand
			for i in range(amount):
				if player.hand.size() > 0:
					var discarded_card = player.hand.pop_back()
					player.discard_pile.append(discarded_card)
		IconTypes.Type.PLAN_TRASH:
			# Trash amount plans from hand
			for i in range(amount):
				if player.hand.size() > 0:
					player.hand.pop_back()  # Card is removed from game
	return true

func _update_icon_and_description():
	icon_texture_path = IconTypes.get_texture_path(icon_type)
	
	match icon_type:
		IconTypes.Type.BLOOD:
			description = "Pay %d blood" % amount
			tag = str(amount)
		IconTypes.Type.MONEY:
			description = "Pay %d money" % amount
			tag = str(amount)
		IconTypes.Type.SECRETS:
			description = "Pay %d secrets" % amount
			tag = str(amount)
		IconTypes.Type.PLAN:
			description = "Discard %d plan(s)" % amount
			tag = str(amount)
		IconTypes.Type.PLAN_TRASH:
			description = "Trash %d plan(s)" % amount
			tag = str(amount)
