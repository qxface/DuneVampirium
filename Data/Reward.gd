class_name Reward
extends ActivationComponent

enum RewardType { GAIN_BLOOD, GAIN_MONEY, GAIN_SECRETS, DRAW_PLAN, DISCARD_PLAN, TRASH_PLAN }

@export var reward_type: RewardType:
	set(value):
		reward_type = value
		_update_icon_and_description(reward_type)
@export var amount: int = 0  # For resource rewards

func _init():
	component_type = ComponentType.REWARD

func execute(player: Player) -> void:
	if not player:
		return
	
	match reward_type:
		RewardType.GAIN_BLOOD:
			player.blood += amount
		RewardType.GAIN_MONEY:
			player.money += amount
		RewardType.GAIN_SECRETS:
			player.secrets += amount
		RewardType.DRAW_PLAN:
			GameActions.draw_plan(player)
		RewardType.DISCARD_PLAN:
			# This would need card context
			pass
		RewardType.TRASH_PLAN:
			# This would need card context
			pass

func _update_icon_and_description(new_reward_type: RewardType):
	match new_reward_type:
		RewardType.GAIN_BLOOD:
			icon_texture_path = "res://assets/icons/resources/blood.png"
			description = "Gain %d blood" % amount
			tag = str(amount) + "+"
		RewardType.GAIN_MONEY:
			icon_texture_path = "res://assets/icons/resources/money.png"
			description = "Gain %d money" % amount
			tag = str(amount) + "+"
		RewardType.GAIN_SECRETS:
			icon_texture_path = "res://assets/icons/resources/secret.png"
			description = "Gain %d secrets" % amount
			tag = str(amount) + "+"
		RewardType.DRAW_PLAN:
			icon_texture_path = "res://assets/piles/draw_pile.png"
			description = "Draw a plan"
			tag = ""
		RewardType.DISCARD_PLAN:
			icon_texture_path = "res://assets/piles/discard_pile.png"
			description = "Discard a plan"
			tag = ""
		RewardType.TRASH_PLAN:
			icon_texture_path = "res://assets/piles/discard_pile.png"  # Need trash icon
			description = "Trash a plan"
			tag = ""
