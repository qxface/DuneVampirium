extends CanvasLayer

# Renders a large view of whatever Space was long-pressed, centered on screen
# and blocking all other input until clicked away. Mirrors CardZoom's approach
# but for Space nodes instead of Cards.

const ZOOM_SCENE: PackedScene = preload("res://game_pieces/space_zoom.tscn")
const DIM_COLOR: Color = Color(0, 0, 0, 0.6)

var _overlay: Control

func _ready() -> void:
	layer = 129

func show_zoom_of(source: Space) -> void:
	if _overlay != null or source == null:
		return

	var zoom_space: Space = ZOOM_SCENE.instantiate()
	zoom_space.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_build_overlay(zoom_space)

	zoom_space.space_data = source.space_data
	zoom_space.position = (get_viewport().get_visible_rect().size - zoom_space.size) / 2.0

func _build_overlay(zoom_space: Control) -> void:
	_overlay = Control.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.gui_input.connect(_on_overlay_input)

	var dim := ColorRect.new()
	dim.color = DIM_COLOR
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(dim)

	_overlay.add_child(zoom_space)
	add_child(_overlay)

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_dismiss()

func _dismiss() -> void:
	if _overlay:
		_overlay.queue_free()
		_overlay = null
