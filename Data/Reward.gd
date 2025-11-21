# res://Data/Reward.gd
class_name Reward
extends ActivationComponent

@export var icon_type: IconTypes.Type = IconTypes.Type.BLOOD:
	set(value):
		icon_type = value
		_update_icon_and_description()
@export var amount: int = 0

func _init():
	component_type = ComponentType.REWARD
	_update_icon_and_description()

func execute(player: Player) -> void:
	if not player:
		return

	match icon_type:
		IconTypes.Type.BLOOD:
			player.blood += amount
		IconTypes.Type.MONEY:
			player.money += amount
		IconTypes.Type.SECRETS:
			player.secrets += amount
		IconTypes.Type.PLAN:
			for i in range(amount):
				GameActions.draw_plan(player)
		IconTypes.Type.INFLUENCE:
			GameActions.gain_influence(player, amount)

func _update_icon_and_description():
	icon_texture_path = IconTypes.get_texture_path(icon_type)

	match icon_type:
		IconTypes.Type.BLOOD:
			description = "Gain %d blood" % amount
			tag = str(amount) + "+"
		IconTypes.Type.MONEY:
			description = "Gain %d money" % amount
			tag = str(amount) + "+"
		IconTypes.Type.SECRETS:
			description = "Gain %d secrets" % amount
			tag = str(amount) + "+"
		IconTypes.Type.PLAN:
			description = "Draw %d plan(s)" % amount
			tag = str(amount) + "+"
		IconTypes.Type.INFLUENCE:
			description = "Gain %d influence" % amount
			tag = str(amount) + "+"
