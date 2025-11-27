# res://BoardParts/PlayerHand/card_hand.gd
class_name CardHand
extends CardBase

var is_hovered: bool = false:
	set(value):
		is_hovered = value
		print("is_hovered set to: ", value)
		_set_border()
var is_chosen: bool = false:
	set(value):
		is_chosen = value
		print("is_chosen set to: ", value, " for card: ", card_data.card_name if card_data else "null")
		_set_border()

func _ready() -> void:
	super()
	print("CardHand _ready() called for: ", card_data.card_name if card_data else "null")
	# If card_data was set before _ready(), ensure signals are connected
	if card_data:
		_connect_signals()
	_minimize_clan_and_origin_icons_only()
	v_split_container.add_theme_constant_override("separation", 1)
	# Force initial border setup
	_set_border()

func _update_display():
	super()
	_minimize_clan_and_origin_icons_only()

func set_card_data(card: Card) -> void:
	print("set_card_data called for: ", card.card_name if card else "null")
	print("Card type: ", card.card_type if card else "N/A")
	# Disconnect any existing signals first
	_disconnect_signals()
	card_data = card
	_update_display()
	# Connect signals based on the new card type
	_connect_signals()
	# Force border update after setting card data
	_set_border()

func _connect_signals() -> void:
	if card_data and card_data.card_type == Card.CardType.PLAN:
		print("Connecting to PLAN signals")
		Signals.plan_chosen.connect(_on_card_chosen)
		Signals.plan_unchosen.connect(_on_card_unchosen)
	elif card_data and card_data.card_type == Card.CardType.MINION:
		print("Connecting to MINION signals")
		Signals.minion_chosen.connect(_on_card_chosen)
		Signals.minion_unchosen.connect(_on_card_unchosen)

func _disconnect_signals() -> void:
	if Signals.plan_chosen.is_connected(_on_card_chosen):
		Signals.plan_chosen.disconnect(_on_card_chosen)
	if Signals.plan_unchosen.is_connected(_on_card_unchosen):
		Signals.plan_unchosen.disconnect(_on_card_unchosen)
	if Signals.minion_chosen.is_connected(_on_card_chosen):
		Signals.minion_chosen.disconnect(_on_card_chosen)
	if Signals.minion_unchosen.is_connected(_on_card_unchosen):
		Signals.minion_unchosen.disconnect(_on_card_unchosen)

func _on_mouse_entered() -> void:
	is_hovered = true
	_emit_zoom_signal(true)
	_set_border()

func _on_mouse_exited() -> void:
	is_hovered = false
	_emit_zoom_signal(false)
	_set_border()

func _on_mouse_left_click() -> void:
	print("Mouse left click on: ", card_data.card_name if card_data else "null")
	if card_data.card_type == Card.CardType.PLAN:
		print("Plan clicked - current Ref.plan_chosen: ", Ref.plan_chosen)
		if Ref.plan_chosen == self:
			print("Deselecting plan")
			Ref.plan_chosen = null
			Signals.plan_unchosen.emit()
		else:
			print("Selecting plan")
			Ref.plan_chosen = self
			Signals.plan_chosen.emit()
	elif card_data.card_type == Card.CardType.MINION:
		print("Minion clicked - current Ref.minion_chosen: ", Ref.minion_chosen)
		if Ref.minion_chosen == self:
			print("Deselecting minion")
			Ref.minion_chosen = null
			Signals.minion_unchosen.emit()
		else:
			print("Selecting minion")
			Ref.minion_chosen = self
			Signals.minion_chosen.emit()

func _on_mouse_right_click() -> void:
	print("CardHand: Right click detected via signal!")
	assert(card_data, "No card_data loaded when discarding.")

	print("Attempting to discard card: ", card_data.card_name)
	if Ref.current_player:
		var success := false
		if card_data.card_type == Card.CardType.PLAN:
			success = GameActions.discard_plan(Ref.current_player, card_data)
		elif card_data.card_type == Card.CardType.MINION:
			success = GameActions.discard_minion(Ref.current_player, card_data)
		
		if success:
			print("Card discarded successfully")
			if get_parent():
				get_parent().remove_child(self)
			queue_free()
			Signals.update_current_player_hand_display.emit()
		else:
			print("Failed to discard card")

func _on_card_chosen() -> void:
	print("_on_card_chosen() called for: ", card_data.card_name if card_data else "null")
	# Fix: Check if this card is the chosen one for its type
	if card_data.card_type == Card.CardType.PLAN:
		var is_this_chosen = (Ref.plan_chosen == self)
		print("Plan check - Ref.plan_chosen == self: ", is_this_chosen)
		is_chosen = is_this_chosen
	elif card_data.card_type == Card.CardType.MINION:
		var is_this_chosen = (Ref.minion_chosen == self)
		print("Minion check - Ref.minion_chosen == self: ", is_this_chosen)
		is_chosen = is_this_chosen

	print("Final is_chosen state: ", is_chosen)
	_set_border()

func _on_card_unchosen() -> void:
	print("_on_card_unchosen() called for: ", card_data.card_name if card_data else "null")
	is_chosen = false
	_set_border()

func _set_border() -> void:
	print("_set_border() called - card_data: ", card_data)
	if not card_data:
		print("WARNING: card_data is null in _set_border!")
		# Apply a default style when card_data is null
		add_theme_stylebox_override("panel", PLAN_NORMAL)
		return
	print("Card type: ", card_data.card_type)
	print("is_chosen: ", is_chosen, " is_hovered: ", is_hovered)
	if card_data.card_type == Card.CardType.PLAN:
		if is_chosen:
			print("Applying PLAN_CHOSEN style")
			add_theme_stylebox_override("panel", PLAN_CHOSEN)
		elif is_hovered:
			print("Applying PLAN_HIGHLIGHT style")
			add_theme_stylebox_override("panel", PLAN_HIGHLIGHT)
		else:
			print("Applying PLAN_NORMAL style")
			add_theme_stylebox_override("panel", PLAN_NORMAL)
	elif card_data.card_type == Card.CardType.MINION:
		if is_chosen:
			print("Applying MINION_CHOSEN style")
			add_theme_stylebox_override("panel", MINION_CHOSEN)
		elif is_hovered:
			print("Applying MINION_HIGHLIGHT style")
			add_theme_stylebox_override("panel", MINION_HIGHLIGHT)
		else:
			print("Applying MINION_NORMAL style")
			add_theme_stylebox_override("panel", MINION_NORMAL)
	else:
		push_error("CardHand._set_border: Invalid Card Type")

func _minimize_clan_and_origin_icons_only() -> void:
	# Set clan and action ColorRect colors from their TextureRects
	primori_bg.color = primori_icon.self_modulate
	volupta_bg.color = volupta_icon.self_modulate
	vorace_bg.color = vorace_icon.self_modulate

	intrigue_bg.color = intrigue_icon.self_modulate
	hunting_bg.color = hunting_icon.self_modulate
	battle_bg.color = battle_icon.self_modulate

	# Set origin ColorRect color directly from the origin_color dictionary (more robust)
	if card_data and card_data.origin in origin_color:
		origin_bg.color = origin_color[card_data.origin]
	else:
		origin_bg.color = Color.WHITE
	 	# Then hide the TextureRects for clan/origin only
	primori_icon.visible = false
	volupta_icon.visible = false
	vorace_icon.visible = false

	intrigue_icon.visible = false
	hunting_icon.visible = false
	battle_icon.visible = false

	origin_icon.visible = false

	# DO NOT hide activation backgrounds - let CardBase._update_display() handle them
	# Hide activation icons (the HBoxContainer children)
	acquire_icons.visible = false
	action_icons.visible = false
	reveal_icons.visible = false
	discard_icons.visible = false
	trash_icons.visible = false

func _emit_zoom_signal(show: bool) -> void:
	if card_data.card_type == Card.CardType.PLAN:
		if show:
			Signals.plan_zoom_show.emit(self)
		else:
			Signals.plan_zoom_hide.emit(self)
	elif card_data.card_type == Card.CardType.MINION:
		if show:
			Signals.minion_zoom_show.emit(self)
		else:
			Signals.minion_zoom_hide.emit(self)

func update_activation_visibility(bg: ColorRect, icons: ActivationIcons, activation: Activation) -> void:
	if not bg:
		print("update_activation_visibility: bg is null")
		return
	var has_activation = activation != null
	var is_not_empty = activation and not activation.is_empty()
	var has_reward = activation and activation.reward and activation.reward.amount > 0
	print("update_activation_visibility - bg:", bg.name, " has_activation:", has_activation, " is_not_empty:", is_not_empty, " has_reward:", has_reward)
	if has_activation and is_not_empty and has_reward:
		bg.visible = true
		if icons:
			icons.visible = true
			icons.update_icons(activation)
		print(bg.name, "- SHOWING")
	else:
		bg.visible = false
		if icons:
			icons.visible = false
		print(bg.name, "- HIDING")
