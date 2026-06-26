class_name Board
extends Node2D

const CARD_SLOT: float  = Card.WIDTH + 4.0   # card width + HBox separation = 179
const PANEL_MARGIN: float = 8.0              # 4 px on each side

# ── Per-panel constants from the design chart ──────────────────────────────
#                         max (cards)  min-occupied (cards)  min-empty (cards)
const MAX_MINION_W:       float = 3.0 * CARD_SLOT + PANEL_MARGIN  # 3 cards
const MIN_MINION_OCC_W:   float = 1.5 * CARD_SLOT + PANEL_MARGIN  # 1.5 cards
const MIN_MINION_EMPTY_W: float = 1.5 * CARD_SLOT + PANEL_MARGIN  # same

const MAX_SEL_MINION_W:       float = 2.0 * CARD_SLOT + PANEL_MARGIN  # 2 cards
const MIN_SEL_MINION_OCC_W:   float = 1.0 * CARD_SLOT + PANEL_MARGIN  # 1 card
# min-empty = 0 (selected panel disappears when empty)

const MAX_PLAN_W:       float = 5.0 * CARD_SLOT + PANEL_MARGIN   # 5 cards
const MIN_PLAN_OCC_W:   float = 1.5 * CARD_SLOT + PANEL_MARGIN   # 1.5 cards
const MIN_PLAN_EMPTY_W: float = 1.5 * CARD_SLOT + PANEL_MARGIN   # same

const MAX_SEL_PLAN_W:       float = 3.0 * CARD_SLOT + PANEL_MARGIN  # 3 cards
const MIN_SEL_PLAN_OCC_W:   float = 1.0 * CARD_SLOT + PANEL_MARGIN  # 1 card
# min-empty = 0

@onready var hand_container: HBoxContainer        = %HandHBoxContainer
@onready var minion_panel: Panel                  = %MinionPanel
@onready var selected_minion_panel: Panel         = %SelectedMinionPanel
@onready var selected_plan_panel: Panel           = %SelectedPlanPanel
@onready var plan_panel: Panel                    = %PlanPanel
@onready var minion_hbox: HBoxContainer           = %MinionHBoxContainer
@onready var selected_minion_hbox: HBoxContainer  = %SelectedMinionHBoxContainer
@onready var selected_plan_hbox: HBoxContainer    = %SelectedPlanHBoxContainer
@onready var plan_hbox: HBoxContainer             = %PlanHBoxContainer

func _ready() -> void:
	add_to_group("BOARD")
	selected_minion_hbox.add_to_group("MINION_HOLDER")
	selected_plan_hbox.add_to_group("PLAN_HOLDER")

	hand_container.sort_children.connect(_raise_selected_panels)
	_raise_selected_panels.call_deferred()
	_update_hand_widths.call_deferred()
	Availability.update.call_deferred()

# Called by cards (via _request_width_update) after any selection change.
func _update_hand_widths() -> void:
	var total: float = hand_container.size.x
	if total <= 0.0:
		return

	var sep: float    = hand_container.get_theme_constant("separation")
	var usable: float = total - 3.0 * sep   # three gaps between four panels

	var m_count:  int = minion_hbox.get_child_count()
	var sm_count: int = selected_minion_hbox.get_child_count()
	var sp_count: int = selected_plan_hbox.get_child_count()
	var p_count:  int = plan_hbox.get_child_count()

	# Selected panels are highest priority — they get their content-based width.
	var sm_w: float = _panel_w(sm_count, MAX_SEL_MINION_W, MIN_SEL_MINION_OCC_W, 0.0)
	var sp_w: float = _panel_w(sp_count, MAX_SEL_PLAN_W,   MIN_SEL_PLAN_OCC_W,  0.0)

	# Natural width each hand would prefer based on its card count.
	var m_nat: float = _panel_w(m_count, MAX_MINION_W, MIN_MINION_OCC_W, MIN_MINION_EMPTY_W)
	var p_nat: float = _panel_w(p_count, MAX_PLAN_W,   MIN_PLAN_OCC_W,   MIN_PLAN_EMPTY_W)

	# When a selected panel is occupied, compress its hand to minimum first.
	var m_w: float = MIN_MINION_EMPTY_W if sm_count > 0 else m_nat
	var p_w: float = MIN_PLAN_EMPTY_W   if sp_count > 0 else p_nat

	# If shrinking the hands leaves the total narrower than the container,
	# give the unused space back to the hands (up to their natural widths).
	var leftover: float = usable - m_w - sm_w - sp_w - p_w
	if leftover > 0.0:
		var m_room: float = m_nat - m_w
		var p_room: float = p_nat - p_w
		var total_room: float = m_room + p_room
		if total_room > 0.0:
			m_w += minf(leftover * m_room / total_room, m_room)
			p_w += minf(leftover * p_room / total_room, p_room)
		elif m_room > 0.0:
			m_w += minf(leftover, m_room)
		elif p_room > 0.0:
			p_w += minf(leftover, p_room)

	# If the total still exceeds usable (e.g. many selected cards), compress
	# panels proportionally down to their minimums.
	var mins: Array[float] = [
		MIN_MINION_EMPTY_W,
		0.0 if sm_count == 0 else MIN_SEL_MINION_OCC_W,
		0.0 if sp_count == 0 else MIN_SEL_PLAN_OCC_W,
		MIN_PLAN_EMPTY_W,
	]
	var widths: Array[float] = [m_w, sm_w, sp_w, p_w]
	var excess: float = widths[0] + widths[1] + widths[2] + widths[3] - usable
	if excess > 0.0:
		var total_headroom: float = 0.0
		for i in 4:
			total_headroom += widths[i] - mins[i]
		if total_headroom > 0.0:
			for i in 4:
				widths[i] -= excess * (widths[i] - mins[i]) / total_headroom
				widths[i] = maxf(widths[i], mins[i])
		m_w = widths[0]; sm_w = widths[1]; sp_w = widths[2]; p_w = widths[3]

	minion_panel.custom_minimum_size.x          = roundi(m_w)
	selected_minion_panel.custom_minimum_size.x = roundi(sm_w)
	selected_plan_panel.custom_minimum_size.x   = roundi(sp_w)
	plan_panel.custom_minimum_size.x            = roundi(p_w)

# Width for a panel given how many cards it currently holds.
func _panel_w(count: int, max_w: float, min_occ_w: float, min_empty_w: float) -> float:
	if count == 0:
		return min_empty_w
	return clampf(float(count) * CARD_SLOT + PANEL_MARGIN, min_occ_w, max_w)

# Moves the selected panels upward so their cards are fully visible on screen.
func _raise_selected_panels() -> void:
	var vh: float = get_viewport().get_visible_rect().size.y
	_align_panel_bottom(selected_minion_panel, Card.HEIGHT, vh)
	_align_panel_bottom(selected_plan_panel,   Card.HEIGHT, vh)

func _align_panel_bottom(panel: Control, card_height: float, viewport_height: float) -> void:
	var target_global_y: float = viewport_height - card_height
	panel.position.y += target_global_y - panel.global_position.y
