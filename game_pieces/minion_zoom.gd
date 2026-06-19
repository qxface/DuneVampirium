class_name MinionZoom
extends Minion

# A Minion that blows itself up to fill the screen vertically (preserving
# its normal proportions) instead of the usual hand-sized CARD_SIZE. Used by
# CardZoom for the long-press "get a closer look" popup - rendering a real,
# full-size Minion looks crisp, where stretching a screenshot of the small
# on-screen card did not.
func _ready() -> void:
	super()
	_resize_to_fill_screen_vertically(CARD_SIZE.x / CARD_SIZE.y)

# Minion's base _setup_styleboxes applies the hand-sized styleboxes verbatim
# - fine at CARD_SIZE, but a corner radius/border width tuned for that size
# (e.g. just barely enough to clamp into a half-circle cap) looks wrong once
# blown up much bigger. Scale each one to match instead.
func _setup_styleboxes() -> void:
	if !is_node_ready():
		await get_tree().process_frame

	image_panel.add_theme_stylebox_override("panel", _make_scaled_stylebox(MINION_TOP))
	actions_panel.add_theme_stylebox_override("panel", _make_scaled_stylebox(MINION_BOTTOM))
	_sb_normal = _make_scaled_stylebox(MINION_NORMAL)
	_sb_selected = _make_scaled_stylebox(MINION_HIGHLIGHT)

	_apply_availability_stylebox()
