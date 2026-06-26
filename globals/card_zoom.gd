extends CanvasLayer

# Renders a large, full-vertical-height view of whatever Card was
# long-pressed on top of everything else, blocking all other input until
# it's clicked away.
#
# Rather than screenshotting the small on-screen card and stretching that
# texture up (which looked pixelated), this instantiates a real MinionZoom
# or PlanZoom scene - a genuine full-size Minion/Plan that sizes itself to
# fill the screen vertically - then copies over the exact card_data and
# availability the player was actually looking at. Letting Godot draw the
# real card art/styleboxes at the larger size keeps everything crisp.

const DIM_COLOR: Color = Color(0, 0, 0, 0.6)

var _overlay: Control

func _ready() -> void:
	# Always render above any other CanvasLayer in the scene.
	layer = 128

func show_zoom_of(source: Card) -> void:
	if _overlay != null or source == null:
		return

	var zoom_scene: PackedScene = source._get_zoom_scene()
	if zoom_scene == null:
		push_warning("CardZoom: %s has no zoom scene defined" % source.name)
		return

	var zoom_card: Card = zoom_scene.instantiate()

	# Never let the big popup itself respond to clicks - it should only be
	# dismissed via the overlay behind it (and this also keeps it from
	# re-triggering its own long-press-to-zoom on top of itself).
	zoom_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_build_overlay(zoom_card)

	# zoom_card's _ready already ran inside _build_overlay's add_child (which
	# randomized its own card_data/availability, same as any fresh
	# Minion/Plan). Overwrite that now with the real data from the card that
	# was actually long-pressed, so the popup matches what's on screen.
	zoom_card.card_data = source.card_data

	zoom_card.position = (get_viewport().get_visible_rect().size - zoom_card.size) / 2.0

func _build_overlay(zoom_card: Control) -> void:
	_overlay = Control.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.gui_input.connect(_on_overlay_input)

	var dim := ColorRect.new()
	dim.color = DIM_COLOR
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(dim)

	_overlay.add_child(zoom_card)
	add_child(_overlay)

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_dismiss()

func _dismiss() -> void:
	if _overlay:
		_overlay.queue_free()
		_overlay = null
