# res://main.gd
# Updated: handles untyped Array returned by PlayerHand.add_plan_hands()
# res://main.gd
# Edit file: res://main.gd
extends Node2D

@onready var previous_player_button: TextureButton = %PreviousPlayerButton
@onready var current_player_label: Label = %CurrentPlayerLabel
@onready var next_player_button: TextureButton = %NextPlayerButton

@onready var player_arrows: HBoxContainer = %PlayerArrows
@onready var player_hand: PlayerHand = %PlayerHand

@onready var plan_zoom: CardZoom = %PlanZoom
@onready var minion_zoom: CardZoom = %MinionZoom
@onready var spacer_zoom_top: Control = %SpacerZoomTop
@onready var spacer_zoom_bottom: Control = %SpacerZoomBottom

func _ready():
	add_to_group("main")
	await get_tree().process_frame
	
	create_players()
	initialize_player_cards()

	next_player_button.pressed.connect(_on_next_player_button_pressed)
	previous_player_button.pressed.connect(_on_previous_player_button_pressed)
	
	Signals.draw_pile_pressed.connect(_on_draw_pile_pressed)
	Signals.draw_pile_right_pressed.connect(_on_draw_pile_right_pressed)
	Signals.discard_pile_pressed.connect(_on_discard_pile_pressed)
	Signals.discard_pile_right_pressed.connect(_on_discard_pile_right_pressed)
	
	Signals.update_current_player_hand_display.connect(update_player_display)
	
	update_player_display()

	# Initialize plan_zoom to be invisible
	if plan_zoom:
		plan_zoom.visible = false
func _on_plan_zoomed(card_data: Card):
	print("Main: Plan hovered (from PlanManager) - ", card_data.card_name)
	if plan_zoom and plan_zoom.has_method("load_card_data"):
		plan_zoom.load_card_data(card_data)
		plan_zoom.visible = true
		print("Main: PlanZoom shown")
func _on_plan_unhovered():
	print("Main: Plan unhovered (from PlanManager)")
	# Only hide if no plan is chosen

func _create_primori_intrigue_card():
	var card = Card.new()
	card.card_name = "Cunning Scheme"
	card.card_description = "A clever Primori intrigue plan"

	# Clan: Primori only
	card.is_primori = true
	card.is_volupta = false
	card.is_vorace = false

	# Action: Intrigue only
	card.is_intrigue = true
	card.is_hunting = false
	card.is_battle = false

	# Origin
	card.origin = Card.OriginType.VAMPIRE

	# Functions: Has reveal and discard
	card.has_reveal = true
	card.has_discard = true

	return card

func _create_volupta_hunting_card():
	var card = Card.new()
	card.card_name = "Luxurious Hunt"
	card.card_description = "A Volupta hunting expedition"

	# Clan: Volupta only
	card.is_primori = false
	card.is_volupta = true
	card.is_vorace = false

	# Action: Hunting only
	card.is_intrigue = false
	card.is_hunting = true
	card.is_battle = false

	# Origin
	card.origin = Card.OriginType.SUPERNATURAL

	# Functions: Has acquire and action
	card.has_acquire = true
	card.has_action = true

	return card

func _create_vorace_battle_card():
	var card = Card.new()
	card.card_name = "Brutal Assault"
	card.card_description = "A Vorace battle plan"

	# Clan: Vorace only
	card.is_primori = false
	card.is_volupta = false
	card.is_vorace = true

	# Action: Battle only
	card.is_intrigue = false
	card.is_hunting = false
	card.is_battle = true

	# Origin
	card.origin = Card.OriginType.HUMAN

	# Functions: Has action and trash
	card.has_action = true
	card.has_trash = true

	return card

func _create_mixed_card():
	var card = Card.new()
	card.card_name = "Master Plan"
	card.card_description = "A complex multi-clan strategy"

	# Clan: Multiple clans
	card.is_primori = true
	card.is_volupta = true
	card.is_vorace = false

	# Action: Multiple actions
	card.is_intrigue = true
	card.is_hunting = true
	card.is_battle = false

	# Origin
	card.origin = Card.OriginType.VAMPIRE

	# Functions: Has multiple functions
	card.has_acquire = true
	card.has_action = true
	card.has_reveal = true
	card.has_discard = true

	return card

func _load_cards_into_dynamic_plan_hands(cards):
	# Get the PlayerHand
	if player_hand == null:
		push_error("PlayerHand not found!")
		return

	# Add new PlanHands for each card
	var plan_hands = player_hand.add_plan_hands(cards.size())

	# Load cards into the new PlanHands
	for i in range(cards.size()):
		var card = cards[i]
		var plan_hand = plan_hands[i]
		plan_hand.load_plan(card)
		print("Loaded card '", card.card_name, "' into dynamically created PlanHand ", i)

# Edit file: res://main.gd
func create_players():
	Ref.players = [
		Player.new("Kaiser", Color.ORANGE),
		Player.new("John-O", Color.GREEN),
		Player.new("Deal", Color.YELLOW),
		Player.new("Andrew", Color.RED)
	]
	
	# Initialize random resources for each player
	for player in Ref.players:
		player.money = randi_range(2, 5)
		player.blood = randi_range(1, 2)
		player.secrets = randi_range(0, 1)

func update_player_display():
	if !Ref.current_player:
		return
	update_current_player_label(Ref.current_player)
	player_hand.update_hand_display(Ref.current_player)
	
func update_current_player_label(player: Player):
	if current_player_label:
		current_player_label.text = "Current Player: " + player.player_name
		# Optional: Set the label color to match the player's color
		current_player_label.add_theme_color_override("font_color", player.player_color)

#func update_draw_pile_display(player: Player):
	#if draw_pile_button:
		## Update the card count label on the draw pile button
		#if draw_pile_button.has_method("update_card_count"):
			#draw_pile_button.update_card_count(player.draw_pile.size())
		#else:
			## Fallback: directly access the label
			#var card_count_label = draw_pile_button.get_node("CardCountLabel")
			#if card_count_label:
				#card_count_label.text = str(player.draw_pile.size())


func initialize_player_cards():
	# Initialize piles and add cards to each player
	for player: Player in Ref.players:
		player.draw_pile = []
		player.discard_pile = []
		player.plan_hand = []
		player.minion_pile = []
 
		# Add the two custom minions first
		var vladimir = CardExamples.create_count_vladimir()
		var skitterfang = CardExamples.create_skitterfang()
		player.minion_pile.append(vladimir)
		player.minion_pile.append(skitterfang)
 
		# Add 2 more random minions
		for i in range(2):
			var random_minion = Helper.create_random_minion()
			player.minion_pile.append(random_minion)
 
		# Add some random plans
		for i in range(5):
			var random_plan = Helper.create_random_plan()
			player.plan_hand.append(random_plan)
 
		# Add cards to draw pile
		for i in range(randi_range(10, 16)):
			var random_card = Helper.create_random_plan()
			player.draw_pile.append(random_card)
 
		print(player.player_name + " - Hand: " + str(player.plan_hand.size()) + " plan cards, Draw Pile: " + str(player.draw_pile.size()) + " plan cards, Minions: " + str(player.minion_pile.size()) + " minion cards")


func draw_cards(player, count: int):
	for i in range(count):
		if player.draw_pile.is_empty():
			# Shuffle discard into draw pile
			player.draw_pile = player.discard_pile.duplicate() if player.discard_pile != null else []
			player.discard_pile.clear()
			if player.draw_pile is Array:
				player.draw_pile.shuffle()
		if player.draw_pile.size() > 0:
			var card = player.draw_pile.pop_back()
			player.plan_hand.append(card)

func _on_previous_player_button_pressed() -> void:
	if Ref.players.is_empty():
		return
	Ref.current_player_index -= 1
	if Ref.current_player_index < 0:
		Ref.current_player_index = Ref.players.size() - 1
	update_player_display()
	# Reconnect signals when player changes
func _on_next_player_button_pressed() -> void:
	if Ref.players.is_empty():
		return
	Ref.current_player_index = (Ref.current_player_index + 1) % Ref.players.size()
	update_player_display()
	# Reconnect signals when player changes

func _on_draw_pile_pressed():
	if GameActions.draw_plan(Ref.current_player):
		# GameActions will update the UI if this was the current player
		pass
func _on_draw_pile_right_pressed():
	pass
func _on_discard_pile_pressed():
	pass
func _on_discard_pile_right_pressed():
	pass


func _on_button_pressed() -> void:
	if Ref.plan_chosen and Ref.plan_chosen.card_data:
		print("Plan: ", Ref.plan_chosen.card_data.card_name)
		Ref.plan_chosen.card_data.action_activation.reward.execute(Ref.current_player)
	else:
		print("Plan: None")
