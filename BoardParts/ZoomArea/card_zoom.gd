# res://BoardParts/ZoomArea/card_zoom.gd
# res://BoardParts/ZoomArea/plan_zoom.gd
# res://BoardParts/PlayerHand/plan_zoom.gd
class_name CardZoom
extends CardBase

var chosen_data: Card

func _ready():
	super()
	
	# Set the appropriate stylebox for minion zoom
	if not display_plans:
		# Ensure minion zoom gets the minion_normal stylebox
		add_theme_stylebox_override("panel", MINION_NORMAL)
	
	icons.custom_minimum_size.y = 100
	v_split_container.add_theme_constant_override("separation", 10)
	
	var transparent_style = StyleBoxEmpty.new()
	v_split_container.add_theme_stylebox_override("dragger", transparent_style)

	# Connect to signals based on display_plans bool
	if display_plans:
		Signals.plan_chosen.connect(_on_card_chosen)
		Signals.plan_unchosen.connect(_on_card_unchosen)
		Signals.plan_zoom_show.connect(_on_card_zoom_show)
		Signals.plan_zoom_hide.connect(_on_card_zoom_hide)
	else:
		Signals.minion_chosen.connect(_on_card_chosen)
		Signals.minion_unchosen.connect(_on_card_unchosen)
		Signals.minion_zoom_show.connect(_on_card_zoom_show)
		Signals.minion_zoom_hide.connect(_on_card_zoom_hide)

func _on_mouse_left_click():
	print("Left Clicked Card Zoom.")

func _on_mouse_right_click():
	print("Right Clicked Card Zoom.")

func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	pass

func _on_card_zoom_show(card_hand: CardHand) -> void:
	if display_plans:
		if card_hand.card_data.card_type == Card.CardType.PLAN:
			set_card_data(card_hand.card_data)
			visible = true
			_update_spacer_visibility()
	else:
		if card_hand.card_data.card_type == Card.CardType.MINION:
			set_card_data(card_hand.card_data)
			visible = true
			_update_spacer_visibility()

func _on_card_zoom_hide(card_hand: CardHand) -> void:
	if display_plans:
		if card_hand.card_data.card_type == Card.CardType.PLAN:
			if !chosen_data:
				visible = false
			else:
				set_card_data(chosen_data)
			_update_spacer_visibility()
	else:
		if card_hand.card_data.card_type == Card.CardType.MINION:
			if !chosen_data:
				visible = false
			else:
				set_card_data(chosen_data)
			_update_spacer_visibility()

func _on_card_chosen() -> void:
	if display_plans:
		if Ref.plan_chosen and Ref.plan_chosen.card_data.card_type == Card.CardType.PLAN:
			chosen_data = Ref.plan_chosen.card_data
			set_card_data(chosen_data)
			visible = true
			_update_spacer_visibility()
	else:
		if Ref.minion_chosen and Ref.minion_chosen.card_data.card_type == Card.CardType.MINION:
			chosen_data = Ref.minion_chosen.card_data
			set_card_data(chosen_data)
			visible = true
			_update_spacer_visibility()

func _on_card_unchosen() -> void:
	chosen_data = null
	# Only hide if no hovered card
	if !card_data:
		visible = false
	_update_spacer_visibility()
	
func _update_spacer_visibility() -> void:
	# Get references to the zoom components and spacers
	var plan_zoom = get_parent().get_node_or_null("PlanZoom") if get_parent() else null
	var minion_zoom = get_parent().get_node_or_null("MinionZoom") if get_parent() else null
	var spacer_zoom_top = get_parent().get_node_or_null("SpacerZoomTop") if get_parent() else null
	var spacer_zoom_bottom = get_parent().get_node_or_null("SpacerZoomBottom") if get_parent() else null
	
	if not spacer_zoom_top or not spacer_zoom_bottom:
		return
	
	# Get visibility states
	var plan_visible = plan_zoom and plan_zoom.visible
	var minion_visible = minion_zoom and minion_zoom.visible
	
	# Apply the logic based on your specifications
	if plan_visible and not minion_visible:
		# ONLY PlanZoom is shown
		spacer_zoom_top.visible = true
		spacer_zoom_bottom.visible = false
	elif not plan_visible and minion_visible:
		# ONLY MinionZoom is shown
		spacer_zoom_top.visible = false
		spacer_zoom_bottom.visible = true
	else:
		# Both are shown or neither are shown
		spacer_zoom_top.visible = false
		spacer_zoom_bottom.visible = false

func _update_display():
	super()
	
	# Ensure minion zoom gets minion styling
	if not display_plans:
		add_theme_stylebox_override("panel", MINION_NORMAL)
	
	_update_activation_icons()
func _update_activation_icons():
	var activation_areas = {
		Card.Activations.ACQUIRE: acquire_icons,
		Card.Activations.ACTION: action_icons,
		Card.Activations.REVEAL: reveal_icons,
		Card.Activations.DISCARD: discard_icons,
		Card.Activations.TRASH: trash_icons
	}

	var activation_bgs = {
		Card.Activations.ACQUIRE: acquire_bg,
		Card.Activations.ACTION: action_bg,
		Card.Activations.REVEAL: reveal_bg,
		Card.Activations.DISCARD: discard_bg,
		Card.Activations.TRASH: trash_bg
	}

	# Hide all activation areas and their background ColorRects first
	for area in activation_areas.values():
		area.visible = false
	for bg in activation_bgs.values():
		bg.visible = false

	# Determine which card data to use (hovered card takes priority over chosen card)
	var current_card_data: Card = card_data if card_data else chosen_data

	# If no card data is set, exit early
	if not current_card_data:
		return

	# Loop through activation areas and find matching activations in current_card_data
	for activation_type: Card.Activations in activation_areas.keys():
		var area: ActivationIcons = activation_areas[activation_type]
		var bg: ColorRect = activation_bgs[activation_type]
		var activation: Activation = current_card_data.get_activation(activation_type)
		if activation:
			area.update_icons(activation)
		# Ensure the background visibility follows whether the icons area is visible
		bg.visible = area.visible
