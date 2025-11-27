# res://Data/GameActions.gd
class_name GameActions
extends Node

# Make it a singleton (autoload)
static var instance: GameActions

func _init():
	instance = self

# Generic game functions that cards can call
static func draw_plan(player: Player) -> bool:
	if player == null:
		print("No player provided")
		return false

	# Check if the player has at least 1 card in their draw_pile
	if player.draw_pile.is_empty():
		print("Draw pile is empty!")
		return false

	# Pop a random card from the draw_pile
	var random_index = randi() % player.draw_pile.size()
	var drawn_card = player.draw_pile.pop_at(random_index)

	# Add the drawn card to the end of the player's hand
	player.plan_hand.append(drawn_card)

	print("Drew card: ", drawn_card.card_name)
	print("New hand size: ", player.plan_hand.size())
	print("Remaining draw pile: ", player.draw_pile.size())

	# Update UI if this is the current player
	Signals.update_current_player_hand_display.emit()

	return true

static func discard_plan(player: Player, card: Card) -> bool:
	if player == null:
		print("No player provided")
		return false
	
	if card == null:
		print("No card provided")
		return false

	# Find the card in the player's hand
	var card_index = player.plan_hand.find(card)
	if card_index == -1:
		print("Card not found in player's hand")
		return false

	# Move card from hand to discard_pile
	player.plan_hand.remove_at(card_index)
	player.discard_pile.append(card)

	print("Discarded card: ", card.card_name)
	print("New hand size: ", player.plan_hand.size())
	print("Discard pile size: ", player.discard_pile.size())

	# Update UI if this is the current player
	Signals.update_current_player_hand_display.emit()

	return true
static func discard_minion(player: Player, minion: Card) -> bool:
	if player and minion and player.minion_pile.has(minion):
		player.minion_pile.erase(minion)
		player.discard_pile.append(minion)
		return true
	return false

static func draw_minion(player: Player) -> void:
	print("Drawing a minion card for ", player.player_name)
	# Implement minion drawing logic here

static func gain_influence(player: Player, amount: int) -> void:
	print(player.player_name, " is gaining ", amount, " influence")
	# Implement influence gain logic here

static func lose_influence(player: Player, amount: int) -> void:
	print(player.player_name, " is losing ", amount, " influence")
	# Implement influence loss logic here

static func move_card_to_trash(player: Player, card: Card) -> void:
	print("Moving card '", card.card_name, "' to trash for ", player.player_name)
	# Implement trash logic here

static func reveal_card(player: Player, card: Card) -> void:
	print("Revealing card '", card.card_name, "' for ", player.player_name)
	# Implement reveal logic here
