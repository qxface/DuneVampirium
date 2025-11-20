# res://Global/helper.gd
extends Node

func odds_fifty_fifty() -> bool:
	return randi_range(0, 1) == 0
	
func odds_low() -> bool:
	return randi_range(0, 3) == 0
	
func odds_high() -> bool:
	return randi_range(0, 3) != 0

func biggest_power_of_2(number: float) -> int:
	if number <= 1:
		return 1
	
	var power = 1
	var result = 1
	
	while result * 2 < number:
		result *= 2
		power += 1
	
	return result

func color_light(color: Color) -> bool:
	var luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b
	return luminance >= 0.5

func create_random_plan() -> Card:
	var card = Card.new()
	card.card_type = Card.CardType.PLAN
	card.card_name = "Plan %s" % randi_range(1, 99)
	card.card_description = "A plan that does %s" % randi_range(1, 99)
	card.origin = Card.OriginType.NONE
	card.is_primori = odds_fifty_fifty()
	card.is_volupta = odds_fifty_fifty()
	card.is_vorace = odds_fifty_fifty()
	card.is_intrigue = odds_fifty_fifty()
	card.is_hunting = odds_fifty_fifty()
	card.is_battle = odds_fifty_fifty()

	# Create random activations using the new system
	if odds_low():
		var reward = Reward.new()
		reward.reward_type = Reward.RewardType.DRAW_PLAN
		reward.tag = ""
		card.acquire_activation = Activation.new(null, null, reward)

	if odds_low():
		var reward = Reward.new()
		reward.reward_type = Reward.RewardType.GAIN_MONEY
		reward.amount = randi_range(1, 3)
		reward.tag = str(reward.amount) + "+"
		card.action_activation = Activation.new(null, null, reward)

	if odds_low():
		var cost = Cost.new()
		cost.cost_type = Cost.CostType.BLOOD
		cost.amount = randi_range(1, 2)
		cost.tag = str(cost.amount) + "-"
		
		var reward = Reward.new()
		reward.reward_type = Reward.RewardType.GAIN_SECRETS
		reward.amount = randi_range(1, 2)
		reward.tag = str(reward.amount) + "+"
		
		card.reveal_activation = Activation.new(null, cost, reward)

	if odds_low():
		var reward = Reward.new()
		reward.reward_type = Reward.RewardType.GAIN_BLOOD
		reward.amount = 1
		reward.tag = "1+"
		card.discard_activation = Activation.new(null, null, reward)

	if odds_low():
		var reward = Reward.new()
		reward.reward_type = Reward.RewardType.GAIN_MONEY
		reward.amount = randi_range(3, 5)
		reward.tag = str(reward.amount) + "+"
		card.trash_activation = Activation.new(null, null, reward)

	# Ensure at least one action type is true
	if not (card.is_intrigue or card.is_hunting or card.is_battle):
		# Randomly select one action type to set to true
		var action_types = ["is_intrigue", "is_hunting", "is_battle"]
		var random_action = action_types[randi() % action_types.size()]
		card.set(random_action, true)

	return card

func create_special_plan() -> Card:
	# 10% chance to create a special card
	if randi_range(1, 10) == 1:
		return CardExamples.create_vamp_out_card()
	else:
		return create_random_plan()

func create_random_minion() -> Card:
	var card = Card.new()
	card.card_type = Card.CardType.MINION
	card.card_name = "Minion %s" % randi_range(1, 99)
	card.card_description = "A minion that is capable of %s" % randi_range(1, 99)
	card.origin = Card.OriginType.NONE
	card.is_primori = odds_fifty_fifty()
	card.is_volupta = odds_fifty_fifty()
	card.is_vorace = odds_fifty_fifty()
	card.is_intrigue = odds_fifty_fifty()
	card.is_hunting = odds_fifty_fifty()
	card.is_battle = odds_fifty_fifty()
	card.has_acquire = odds_fifty_fifty()
	card.has_action = odds_fifty_fifty()
	card.has_reveal = odds_fifty_fifty()
	card.has_discard = odds_fifty_fifty()
	card.has_trash = odds_fifty_fifty()
	
	return card

func find_parent_rect_color(scene: Control) -> Color:
	var parent_color:= Color.WHITE
	var current_parent = scene.get_parent()
	while current_parent:
		if current_parent is ColorRect:
			parent_color = current_parent.color
		current_parent = current_parent.get_parent()
	
	return parent_color
