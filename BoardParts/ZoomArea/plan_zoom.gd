# res://BoardParts/ZoomArea/plan_zoom.gd
# res://BoardParts/PlayerHand/plan_zoom.gd
class_name PlanZoom
extends PlanBase

var chosen_card_data: Card

func _ready():
	super()
	
	icons.custom_minimum_size.y = 100
	
	#zoom_icon(primori_icon)
	#zoom_icon(volupta_icon)
	#zoom_icon(vorace_icon)
	#
	#zoom_icon(intrigue_icon)
	#zoom_icon(hunting_icon)
	#zoom_icon(battle_icon)
	#
	#zoom_icon(origin_icon)
	
	Signals.plan_chosen.connect(_on_plan_chosen)
	Signals.plan_unchosen.connect(_on_plan_unchosen)
	Signals.plan_zoom_show.connect(_on_plan_zoom_show)
	Signals.plan_zoom_hide.connect(_on_plan_zoom_hide)

func _on_mouse_left_click():
	print("Left Clicked Plan Zoom.")

func _on_mouse_right_click():
	print("Right Clicked Plan Zoom.")

func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	pass

func _on_plan_zoom_show(new_plan_hand: PlanHand) -> void:
	set_card_data(new_plan_hand.card_data)
	visible = true

func _on_plan_zoom_hide(new_plan_hand: PlanHand) -> void:
	if !chosen_card_data:
		visible = false
	else:
		set_card_data(chosen_card_data)

func _on_plan_chosen() -> void:
	chosen_card_data = Ref.plan_chosen.card_data
	
func _on_plan_unchosen() -> void:
	chosen_card_data = null

func _update_display():
	super()
	_update_activation_icons()


func _update_activation_icons():
	var activation_areas = {
		Card.Activations.ACQUIRE: acquire_icons,
		Card.Activations.ACTION: action_icons,
		Card.Activations.REVEAL: reveal_icons,
		Card.Activations.DISCARD: discard_icons,
		Card.Activations.TRASH: trash_icons
	}

	# Hide all activation areas first
	for area in activation_areas.values():
		area.visible = false

	# Determine which card data to use (hovered card takes priority over chosen card)
	var current_card_data: Card = card_data if card_data else chosen_card_data

	# If no card data is set, exit early
	if not current_card_data:
		return

	# Loop through activation areas and find matching activations in current_card_data
	for activation_type: Card.Activations in activation_areas.keys():
		var area: ActivationIcons = activation_areas[activation_type]
		var activation: Activation = current_card_data.get_activation(activation_type)
		if activation:
			area.update_icons(activation)
