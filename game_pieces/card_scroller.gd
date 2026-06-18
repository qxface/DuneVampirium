extends ScrollContainer

var _dragging := false
var _drag_start_x := 0
var _scroll_start_horizontal := 0
var _drag_threshold := 10

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
			scroll_horizontal = _scroll_start_horizontal - int(delta_x)
			get_viewport().set_input_as_handled()
