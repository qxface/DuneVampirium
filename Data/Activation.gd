class_name Activation
extends Resource

@export var requirement: Requirement
@export var cost: Cost
@export var reward: Reward

# Empty activation that always returns false
static var EMPTY: Activation:
	get:
		var empty = Activation.new()
		empty.requirement = Requirement.new()
		empty.cost = Cost.new()
		empty.reward = Reward.new()
		return empty

func _init(p_requirement: Requirement = null, p_cost: Cost = null, p_reward: Reward = null):
	requirement = p_requirement if p_requirement else Requirement.new()
	cost = p_cost if p_cost else Cost.new()
	reward = p_reward if p_reward else Reward.new()

# Check if activation can be used (requirement met AND cost can be paid)
func is_usable(player: Player) -> bool:
	if not player:
		return false
	
	# Check if we have a valid requirement
	var requirement_met = true
	if requirement and requirement.comparison != "":
		requirement_met = requirement.is_met(player)
	
	# Check if we have a valid cost
	var cost_can_pay = true
	if cost and (cost.amount > 0 or cost.cost_type in [Cost.CostType.DISCARD_PLAN, Cost.CostType.TRASH_PLAN]):
		cost_can_pay = cost.can_pay(player)
	
	return requirement_met and cost_can_pay

# Execute the activation (pay cost then get reward)
func execute(player: Player) -> bool:
	if not is_usable(player):
		return false
	
	# Pay the cost first
	var cost_paid = true
	if cost and (cost.amount > 0 or cost.cost_type in [Cost.CostType.DISCARD_PLAN, Cost.CostType.TRASH_PLAN]):
		cost_paid = cost.pay(player)
	
	if not cost_paid:
		return false
	
	# Then execute the reward
	if reward:
		reward.execute(player)
	
	return true

# Check if this activation is empty (has no real functionality)
func is_empty() -> bool:
	return (requirement == null or requirement.comparison == "") and \
		   (cost == null or (cost.amount == 0 and cost.cost_type not in [Cost.CostType.DISCARD_PLAN, Cost.CostType.TRASH_PLAN])) and \
		   (reward == null or reward.reward_type == Reward.RewardType.GAIN_BLOOD and reward.amount == 0)
