# res://Global/helper.gd
extends Node

# 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
# https://github.com/qxface/DuneVampirium

func odds_fifty_fifty() -> bool:
	return randi_range(0, 1) == 0
	
func odds_low() -> bool:
	return randi_range(0, 3) == 0
	
func odds_high() -> bool:
	return randi_range(0, 3) != 0

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
	
	if odds_low():
		card.acquire_func = GameActions.draw_plan.bind(Ref.current_player)
	if odds_low():
		card.action_func = GameActions.draw_plan.bind(Ref.current_player)
	if odds_low():
		card.reveal_func = GameActions.draw_plan.bind(Ref.current_player)
	if odds_low():
		card.discard_func = GameActions.draw_plan.bind(Ref.current_player)
	if odds_low():
		card.trash_func = GameActions.draw_plan.bind(Ref.current_player)

	# Ensure at least one action type is true
	if not (card.is_intrigue or card.is_hunting or card.is_battle):
		# Randomly select one action type to set to true
		var action_types = ["is_intrigue", "is_hunting", "is_battle"]
		var random_action = action_types[randi() % action_types.size()]
		card.set(random_action, true)

	return card

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
