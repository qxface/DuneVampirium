# res://Data/CardExamples.gd
# Edit file: res://Data/CardExamples.gd
class_name CardExamples
extends Node

# Create the "Simple Card" - a basic test card with 3 money reward and 1 blood cost
static func create_simple_card() -> Card:
	var card = Card.new()
	
	# Basic card properties
	card.card_name = "Simple Card"
	card.card_description = "A simple test card that gives 3 money for 1 blood"
	card.card_type = Card.CardType.PLAN
	
	# Clan and action properties (minimal setup)
	card.is_primori = true
	card.is_volupta = false
	card.is_vorace = false
	card.is_intrigue = true
	card.is_hunting = false
	card.is_battle = false
	card.origin = Card.OriginType.NONE
	
	#var requirement:= Requirement.new()
	#requirement.requirement_type = Requirement.RequirementType.SECRETS
	#requirement.amount = 1
	#requirement.tag = "1"
	#
	#var cost:= Cost.new()
	#cost.cost_type = Cost.CostType.BLOOD
	#cost.amount = 1
	#cost.tag = "1"
	
	var reward:= Reward.new()
	reward.reward_type = Reward.RewardType.DRAW_PLAN
	reward.amount = 3
	reward.tag = ""
	
	card.action_activation = Activation.new(null, null, reward)
	
	#requirement = Requirement.new()
	#requirement.requirement_type = Requirement.RequirementType.SECRETS
	#requirement.amount = 1
	#requirement.tag = "1"
	#
	#cost = Cost.new()
	#cost.cost_type = Cost.CostType.BLOOD
	#cost.amount = 1
	#cost.tag = "1"
	#
	#reward = Reward.new()
	#reward.reward_type = Reward.RewardType.GAIN_MONEY
	#reward.amount = 3
	#reward.tag = "3"
	#
	#card.trash_activation = Activation.new(requirement, cost, reward)
	
	return card


# Create the "Vamp Out!" card with all the specified activations
static func create_vamp_out_card() -> Card:
	var card = Card.new()
	
	# Basic card properties
	card.card_name = "Vamp Out!"
	card.card_description = "This is a test card that has lots of different activations"
	card.card_type = Card.CardType.PLAN
	
	# Clan and action properties
	card.is_primori = true
	card.is_intrigue = true
	card.is_hunting = true
	card.origin = Card.OriginType.NONE
	
	# Create activations
	
	# 1. Acquire: "Gain 2 Money" (reward only)
	var acquire_reward = Reward.new()
	acquire_reward.reward_type = Reward.RewardType.GAIN_MONEY
	acquire_reward.amount = 2
	acquire_reward.tag = "2+"
	
	card.acquire_activation = Activation.new(null, null, acquire_reward)
	
	# 2. Action: requirement: "1+ blood", reward: "2 Money"
	var action_requirement = Requirement.new()
	action_requirement.requirement_type = Requirement.RequirementType.BLOOD
	action_requirement.comparison = "1+"
	action_requirement.tag = "1+"
	
	var action_reward = Reward.new()
	action_reward.reward_type = Reward.RewardType.GAIN_MONEY
	action_reward.amount = 2
	action_reward.tag = "2+"
	
	card.action_activation = Activation.new(action_requirement, null, action_reward)
	
	# 3. Reveal: cost: "1 blood", reward: "1 secret"
	var reveal_cost = Cost.new()
	reveal_cost.cost_type = Cost.CostType.BLOOD
	reveal_cost.amount = 1
	reveal_cost.tag = "1-"
	
	var reveal_reward = Reward.new()
	reveal_reward.reward_type = Reward.RewardType.GAIN_SECRETS
	reveal_reward.amount = 1
	reveal_reward.tag = "1+"
	
	card.reveal_activation = Activation.new(null, reveal_cost, reveal_reward)
	
	# 4. Discard: reward: "1 blood"
	var discard_reward = Reward.new()
	discard_reward.reward_type = Reward.RewardType.GAIN_BLOOD
	discard_reward.amount = 1
	discard_reward.tag = "1+"
	
	card.discard_activation = Activation.new(null, null, discard_reward)
	
	# 5. Trash: reward: "5 money"
	var trash_reward = Reward.new()
	trash_reward.reward_type = Reward.RewardType.GAIN_MONEY
	trash_reward.amount = 5
	trash_reward.tag = "5+"
	
	card.trash_activation = Activation.new(null, null, trash_reward)
	
	return card

# Test function to add the card to a player's hand
static func test_vamp_out_card(player: Player) -> void:
	if player:
		var vamp_out_card = create_vamp_out_card()
		player.hand.append(vamp_out_card)
		print("Added 'Vamp Out!' card to ", player.player_name, "'s hand")
		print("Card has activations:")
		print("- Acquire: ", vamp_out_card.has_acquire)
		print("- Action: ", vamp_out_card.has_action)
		print("- Reveal: ", vamp_out_card.has_reveal)
		print("- Discard: ", vamp_out_card.has_discard)
		print("- Trash: ", vamp_out_card.has_trash)
	else:
		print("No player provided for testing")

# You can also add this to your main.gd to test it:
# In main.gd, add this to _ready() or create a test function:
# CardExamples.test_vamp_out_card(Ref.current_player)
