# res://Data/Activation.gd
class_name Activation
extends Resource

@export var requirement: Requirement
@export var cost: Cost
@export var reward: Reward

# Empty activation that always returns false
static var EMPTY: Activation:
	get:
		var empty = Activation.new()
		# Create truly empty components
		empty.requirement = null
		empty.cost = null
		empty.reward = null
		return empty

func _init(p_requirement: Requirement = null, p_cost: Cost = null, p_reward: Reward = null):
	requirement = p_requirement
	cost = p_cost
	reward = p_reward

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
	if cost and (cost.amount > 0 or cost.icon_type in [IconTypes.Type.PLAN, IconTypes.Type.PLAN_TRASH]):
		cost_can_pay = cost.can_pay(player)
	
	return requirement_met and cost_can_pay

# Execute the activation (pay cost then get reward)
func execute(player: Player) -> bool:
	if not is_usable(player):
		return false
	
	# Pay the cost first
	var cost_paid = true
	if cost and (cost.amount > 0 or cost.icon_type in [IconTypes.Type.PLAN, IconTypes.Type.PLAN_TRASH]):
		cost_paid = cost.pay(player)
	
	if not cost_paid:
		return false
	
	# Then execute the reward
	if reward:
		reward.execute(player)
	
	return true

# Check if this activation is empty (has no real functionality)
func is_empty() -> bool:
	var req_empty = requirement == null or requirement.comparison == ""
	var cost_empty = cost == null or (cost.amount == 0 and cost.icon_type not in [IconTypes.Type.PLAN, IconTypes.Type.PLAN_TRASH])
	var reward_empty = reward == null or reward.amount == 0
	#print("Activation.is_empty() check:")
	#print("  Requirement empty: ", req_empty, " (requirement: ", requirement, ", comparison: ", requirement.comparison if requirement else "null", ")")
	#print("  Cost empty: ", cost_empty, " (cost: ", cost, ", amount: ", cost.amount if cost else "null", ", icon_type: ", cost.icon_type if cost else "null", ")")
	#print("  Reward empty: ", reward_empty, " (reward: ", reward, ", amount: ", reward.amount if reward else "null", ")")
	#print("  Overall empty: ", req_empty and cost_empty and reward_empty)
	return req_empty and cost_empty and reward_empty
