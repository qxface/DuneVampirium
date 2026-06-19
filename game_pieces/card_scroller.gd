extends ScrollContainer

const SCROLL_DURATION: float = 0.25

var _dragging := false
var _drag_start_x := 0
var _scroll_start_horizontal := 0
var _drag_threshold := 10

var _scroll_tween: Tween

# Smoothly scrolls so the given local x-range (e.g. a card's position and
# size, in the content child's coordinate space) is fully within view.
# Does nothing if the range is already fully visible.
func ensure_range_visible(left: float, right: float) -> void:
	var view_left: float = float(scroll_horizontal)
	var view_right: float = view_left + size.x

	var target_scroll: float = view_left
	if left < view_left:
		target_scroll = left
	elif right > view_right:
		target_scroll = right - size.x

	target_scroll = clamp(target_scroll, 0.0, float(get_h_scroll_bar().max_value - size.x))

	if int(target_scroll) == scroll_horizontal:
		return

	if _scroll_tween:
		_scroll_tween.kill()
	_scroll_tween = create_tween()
	_scroll_tween.tween_property(self, "scroll_horizontal", int(target_scroll), SCROLL_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var local_pos = get_local_mouse_position()
				if Rect2(Vector2(), size).has_point(local_pos):
					_dragging = true
					_drag_start_x = event.position.x
					_scroll_start_horizontal = scroll_horizontal
			else:
				if _dragging:
					_dragging = false
	
	if event is InputEventMouseMotion and _dragging:
		var delta_x: float = event.position.x - _drag_start_x
		if abs(delta_x) > _drag_threshold:
			# The press that started this drag landed on some card; if it was
			# mid-long-press, the player is scrolling instead of holding
			# still to inspect it, so don't let the zoom popup fire.
			_cancel_pending_long_presses()
			scroll_horizontal = _scroll_start_horizontal - int(delta_x)
			get_viewport().set_input_as_handled()

# Cancels any card's pending long-press timer. At most one card can
# realistically be mid-press when a scroll drag starts, so it's simplest to
# just sweep the whole CARD group rather than track which one was pressed.
func _cancel_pending_long_presses() -> void:
	for card in get_tree().get_nodes_in_group("CARD"):
		if card is Card:
			card.cancel_long_press()
