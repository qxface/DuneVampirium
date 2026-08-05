extends CanvasLayer

# Lets a player choose one or more DISTINCT factions to advance (see AdvanceWildFaction).
# Requests are queued: if a second request comes in while one is already showing (e.g. a
# Space with two separate single-pick Wild effects fired in the same batch), it waits its
# turn rather than clobbering the request in progress. Distinctness is scoped to a single
# request, so the same faction CAN be picked again across two separate requests — only a
# single request asking for 2+ picks forces those picks to differ.

class _Request:
	var choices: Array = []
	var count: int = 1
	var callback: Callable
	var picked: Array = []

var _queue: Array = []

var _overlay: ColorRect
var _panel: Panel
var _message_label: Label
var _icon_hbox: HBoxContainer

func _ready() -> void:
	layer = 10
	visible = false
	_build_ui()

func _build_ui() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.72)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	_panel = Panel.new()
	_panel.anchor_left   = 0.2
	_panel.anchor_top    = 0.3
	_panel.anchor_right  = 0.8
	_panel.anchor_bottom = 0.7
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	vbox.offset_left   = 24.0
	vbox.offset_top    = 16.0
	vbox.offset_right  = -24.0
	vbox.offset_bottom = -16.0
	_panel.add_child(vbox)

	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(_message_label)

	_icon_hbox = HBoxContainer.new()
	_icon_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_icon_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_icon_hbox.add_theme_constant_override("separation", 24)
	vbox.add_child(_icon_hbox)

# Requests `count` DISTINCT factions chosen from `choices` (typically
# GameState.faction_tracks.keys()). Calls `callback` with an Array of the chosen
# faction-name Strings once all `count` picks are made. Queues behind any
# already-showing request rather than interrupting it.
func request_picks(choices: Array, count: int, callback: Callable) -> void:
	var req := _Request.new()
	req.choices = choices.duplicate()
	req.count = max(1, count)
	req.callback = callback
	_queue.append(req)
	if _queue.size() == 1:
		_show_current()

func _show_current() -> void:
	if _queue.is_empty():
		visible = false
		return
	_rebuild_icons(_queue[0])
	visible = true

func _rebuild_icons(req: _Request) -> void:
	for child in _icon_hbox.get_children():
		child.queue_free()

	var remaining: int = req.count - req.picked.size()
	_message_label.text = "Select a faction to gain influence with." if remaining <= 1 \
		else "Select a faction to gain influence with. (%d more to choose)" % remaining

	for faction_name: String in req.choices:
		if faction_name in req.picked:
			continue
		var button := Button.new()
		button.custom_minimum_size = Vector2(160, 180)
		button.text = faction_name.capitalize()
		button.add_theme_font_size_override("font_size", 22)
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		var path := "res://assets/icons/clans/%s.png" % faction_name
		if ResourceLoader.exists(path):
			button.icon = load(path)
		button.pressed.connect(_on_faction_picked.bind(req, faction_name))
		_icon_hbox.add_child(button)

func _on_faction_picked(req: _Request, faction_name: String) -> void:
	if faction_name in req.picked:
		return
	req.picked.append(faction_name)
	if req.picked.size() >= req.count:
		_queue.pop_front()
		req.callback.call(req.picked)
		_show_current()
	else:
		_rebuild_icons(req)
