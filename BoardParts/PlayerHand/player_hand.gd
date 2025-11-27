# res://BoardParts/PlayerHand/player_hand.gd
# TODO: Verified - no calls to empty() found in this file; ensure is_empty() is used where needed.
class_name PlayerHand
extends MarginContainer

const PLAN_HAND = preload("res://BoardParts/PlayerHand/card_hand.tscn")
const PLAN_WIDTH: int = 75
const MINION_HAND = PLAN_HAND
const MINION_WIDTH: int = 75

@onready var top_row: HBoxContainer = %TopRow
@onready var bottom_row: HBoxContainer = %BottomRow
@onready var draw_pile: Pile = %DrawPile
@onready var discard_pile: Pile = %DiscardPile

func _ready():
	# Remove all existing PlanHandCards from BottomRow
	_clear_existing_card_hands()

func _clear_existing_card_hands():
	# Find and remove all PlanHandCard children
	var children_to_remove = []
	for child in bottom_row.get_children():
		if child is CardHand:
			children_to_remove.append(child)
	for child in children_to_remove:
		bottom_row.remove_child(child)
		child.queue_free()
	
	children_to_remove.clear()
	for child in top_row.get_children():
		if child is CardHand:
			children_to_remove.append(child)
	for child in children_to_remove:
		top_row.remove_child(child)
		child.queue_free()
	
	# Remove the children
	
	print("Removed ", children_to_remove.size(), " existing PlanHandCards")

# Function to add a new PlanHandCard dynamically
func add_plan_hand() -> Control:
	var plan_hand = PLAN_HAND.instantiate()
	bottom_row.add_child(plan_hand)
	return plan_hand
# Function to add a new MinionHandCard dynamically
func add_minion_hand() -> Control:
	var minion_hand = PLAN_HAND.instantiate()
	top_row.add_child(minion_hand)
	return minion_hand

# Function to add multiple PlanHandCards
func add_plan_hands(count: int):
	var plan_hands = []
	for i in range(count):
		var plan_hand = add_plan_hand()
		if plan_hand:
			plan_hands.append(plan_hand)
			_set_plan_hand_sizing(plan_hand)
	return plan_hands

# Function to add multiple MinionHandCards
func add_minion_hands(count: int):
	var minion_hands = []
	for i in range(count):
		var minion_hand = add_minion_hand()
		if minion_hand:
			minion_hands.append(minion_hand)
			_set_minion_hand_sizing(minion_hand)
	return minion_hands

func update_hand_display(player: Player):
	if player == null:
		return
	# Update draw pile count
	if draw_pile and draw_pile.has_method("update_card_count"):
		draw_pile.update_card_count(player.draw_pile.size())
	# Update discard pile count (if discard_pile_button exists)
	if discard_pile and discard_pile.has_method("update_card_count"):
		discard_pile.update_card_count(player.discard_pile.size())
	# Clear existing hand display
	_clear_existing_card_hands()
	# Create minion displays for each minion in pile (TopRow)
	for minion in player.minion_pile:
		var minion_hand_instance: CardHand = PLAN_HAND.instantiate()
		minion_hand_instance.player = player
		top_row.add_child(minion_hand_instance)
		if minion_hand_instance.has_method("set_card_data"):
			minion_hand_instance.set_card_data(minion)
		elif minion_hand_instance.has_method('load_minion'):
			minion_hand_instance.load_minion(minion)
		_set_minion_hand_sizing(minion_hand_instance)
	# Create card displays for each card in hand (BottomRow)
	for card in player.plan_hand:
		var hand_card_instance: CardHand = PLAN_HAND.instantiate()
		hand_card_instance.player = player
		# Prefer set_card_data if the PlanHandCard scene exposes it, otherwise fall back to load_plan
		bottom_row.add_child(hand_card_instance)
		if hand_card_instance.has_method("set_card_data"):
			hand_card_instance.set_card_data(card)
		elif hand_card_instance.has_method('load_plan'):
			hand_card_instance.load_plan(card)
		_set_plan_hand_sizing(hand_card_instance)
	print("Updated hand display for ", player.player_name)
	print("Minions: ", player.minion_pile.size())
	print("Hand size: ", player.plan_hand.size())
	print("Draw pile: ", player.draw_pile.size())
	print("Discard pile: ", player.discard_pile.size())
func _set_plan_hand_sizing(plan_hand: Control):
	plan_hand.custom_minimum_size.x = PLAN_WIDTH
	# Set horizontal sizing flags to shrink center
	plan_hand.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	# Also set vertical sizing to shrink center for consistency
	plan_hand.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _set_minion_hand_sizing(minion_hand: Control):
	minion_hand.custom_minimum_size.x = MINION_WIDTH
	# Set horizontal sizing flags to shrink center
	minion_hand.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	# Also set vertical sizing to shrink center for consistency
	minion_hand.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _on_draw_pile_pressed() -> void:
	Signals.draw_pile_pressed.emit()

func _on_draw_pile_right_pressed() -> void:
	Signals.draw_pile_right_pressed.emit()

func _on_discard_pile_pressed() -> void:
	Signals.discard_pile_pressed.emit()

func _on_discard_pile_right_pressed() -> void:
	Signals.discard_pile_right_pressed.emit()
