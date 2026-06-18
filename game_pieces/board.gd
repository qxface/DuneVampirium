class_name Board
extends Node2D

@onready var selected_minion_holder: Control = %SelectedMinionHolder
@onready var selected_plan_holder: Control = %SelectedPlanHolder

func _ready() -> void:
	# Cards look up their holder via group, by type (see Card._get_holder).
	selected_minion_holder.add_to_group("MINION_HOLDER")
	selected_plan_holder.add_to_group("PLAN_HOLDER")

	selected_minion_holder.custom_minimum_size.x = Minion.CARD_SIZE.x
	selected_plan_holder.custom_minimum_size.x = Plan.CARD_SIZE.x

	# HandHBoxContainer's own rect hangs below the bottom of the screen (see
	# its offsets) so that most of a card in the scrolling hand stays hidden,
	# with only the top peeking up into view. The holders need to clear that,
	# so pin each one's bottom edge to the bottom of the visible screen
	# rather than wherever the row's default layout would put it. Reapplied
	# every time the row lays itself out (its position gets reset to the
	# container-computed default first), so this stays correct across
	# resizes rather than drifting.
	var hand_row: Container = selected_minion_holder.get_parent() as Container
	if hand_row:
		hand_row.sort_children.connect(_raise_holders)
	_raise_holders.call_deferred()

func _raise_holders() -> void:
	var viewport_height: float = get_viewport().get_visible_rect().size.y
	_align_holder_bottom_to_viewport(selected_minion_holder, Minion.CARD_SIZE.y, viewport_height)
	_align_holder_bottom_to_viewport(selected_plan_holder, Plan.CARD_SIZE.y, viewport_height)

# Shifts holder.position.y (its parent-relative layout position) just enough
# that its global bottom edge lands exactly on the bottom of the screen.
func _align_holder_bottom_to_viewport(holder: Control, card_height: float, viewport_height: float) -> void:
	var target_global_y: float = viewport_height - card_height
	holder.position.y += target_global_y - holder.global_position.y
