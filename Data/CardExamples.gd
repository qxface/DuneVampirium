# res://Data/CardExamples.gd
# Edit file: res://Data/CardExamples.gd
class_name CardExamples
extends Node

# Create the 'Simple Card' - a basic test card with Action and Reveal activations
static func create_simple_plan() -> Card:
	var card = Card.new()
	
	# Basic card properties
	card.card_name = "Simple Card"
	card.card_description = "A simple test card with Action and Reveal activations"
	card.card_type = Card.CardType.PLAN
	
	# Clan and action properties (minimal setup)
	card.is_primori = false
	card.is_volupta = false
	card.is_vorace = false
	card.is_intrigue = false
	card.is_hunting = false
	card.is_battle = false
	card.origin = Card.OriginType.NONE
	
	# Action Activation: Draw 3 plans (reward only)
	var action_reward:= Reward.new()
	action_reward.icon_type = IconTypes.Type.SECRETS
	action_reward.amount = 3
	action_reward.tag = "3"
	card.action_activation = Activation.new(null, null, action_reward)
	
	# Reveal Activation: Cost 1 blood, Reward 1 secret
	var reveal_cost:= Cost.new()
	reveal_cost.icon_type = IconTypes.Type.BLOOD
	reveal_cost.amount = 1
	reveal_cost.tag = "1"
	
	var reveal_reward:= Reward.new()
	reveal_reward.icon_type = IconTypes.Type.SECRETS
	reveal_reward.amount = 1
	reveal_reward.tag = "1"
	
	card.reveal_activation = Activation.new(null, reveal_cost, reveal_reward)
	
	return card

# Create Count Vladimir - aristocratic vampire minion
static func create_count_vladimir() -> Card:
	var card = Card.new()
	
	# Basic card properties
	card.card_name = "Count Vladimir"
	card.card_description = "An aristocratic Primori vampire with a taste for intrigue"
	card.card_type = Card.CardType.MINION
	
	# Clan and action properties
	card.is_primori = true
	card.is_intrigue = true
	card.origin = Card.OriginType.VAMPIRE
	
	# Activation 1: Action - Gain 2 secrets (intrigue action)
	var action_reward = Reward.new()
	action_reward.icon_type = IconTypes.Type.SECRETS
	action_reward.amount = 2
	action_reward.tag = "2"
	card.action_activation = Activation.new(null, null, action_reward)
	
	# Activation 2: Reveal - Cost 1 blood, Gain 1 money
	var reveal_cost = Cost.new()
	reveal_cost.icon_type = IconTypes.Type.BLOOD
	reveal_cost.amount = 1
	reveal_cost.tag = "1"
	
	var reveal_reward = Reward.new()
	reveal_reward.icon_type = IconTypes.Type.MONEY
	reveal_reward.amount = 1
	reveal_reward.tag = "1"
	
	card.reveal_activation = Activation.new(null, reveal_cost, reveal_reward)
	
	return card

# Create Skitterfang - wererat minion
static func create_skitterfang() -> Card:
	var card = Card.new()
	
	# Basic card properties
	card.card_name = "Skitterfang"
	card.card_description = "A cunning wererat ally with hunting and battle prowess"
	card.card_type = Card.CardType.MINION
	
	# Action properties (no clans)
	card.is_hunting = true
	card.is_battle = true
	card.origin = Card.OriginType.SUPERNATURAL
	
	# Activation 1: Action - Gain 1 blood (hunting action)
	var action_reward = Reward.new()
	action_reward.icon_type = IconTypes.Type.BLOOD
	action_reward.amount = 1
	action_reward.tag = "1"
	card.action_activation = Activation.new(null, null, action_reward)
	
	# Activation 2: Reveal - Gain 2 money
	var reveal_reward = Reward.new()
	reveal_reward.icon_type = IconTypes.Type.MONEY
	reveal_reward.amount = 2
	reveal_reward.tag = "2"
	card.reveal_activation = Activation.new(null, null, reveal_reward)
	
	# Activation 3: Discard - Gain 1 secret
	var discard_reward = Reward.new()
	discard_reward.icon_type = IconTypes.Type.SECRETS
	discard_reward.amount = 1
	discard_reward.tag = "1"
	card.discard_activation = Activation.new(null, null, discard_reward)
	
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
	acquire_reward.icon_type = IconTypes.Type.MONEY
	acquire_reward.amount = 2
	card.acquire_activation = Activation.new(null, null, acquire_reward)
	
	# 2. Action: requirement: "1+ blood", reward: "2 Money"
	var action_requirement = Requirement.new()
	action_requirement.icon_type = IconTypes.Type.BLOOD
	action_requirement.amount = 1
	action_requirement.comparison = "+"

	var action_reward = Reward.new()
	action_reward.icon_type = IconTypes.Type.MONEY
	action_reward.amount = 2
	
	card.action_activation = Activation.new(action_requirement, null, action_reward)
	
	# 3. Reveal: cost: "1 blood", reward: "1 secret"
	var reveal_cost = Cost.new()
	reveal_cost.icon_type = IconTypes.Type.BLOOD
	reveal_cost.amount = 1

	var reveal_reward = Reward.new()
	reveal_reward.icon_type = IconTypes.Type.SECRETS
	reveal_reward.amount = 1
	
	card.reveal_activation = Activation.new(null, reveal_cost, reveal_reward)
	
	# 4. Discard: reward: "1 blood"
	var discard_reward = Reward.new()
	discard_reward.icon_type = IconTypes.Type.BLOOD
	discard_reward.amount = 1
	
	card.discard_activation = Activation.new(null, null, discard_reward)
	
	# 5. Trash: reward: "5 money"
	var trash_reward = Reward.new()
	trash_reward.icon_type = IconTypes.Type.MONEY
	trash_reward.amount = 5
	
	card.trash_activation = Activation.new(null, null, trash_reward)
	
	return card

# Test function to add the card to a player's hand
static func test_vamp_out_card(player: Player) -> void:
	if player:
		var vamp_out_card = create_vamp_out_card()
		player.plan_hand.append(vamp_out_card)
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
