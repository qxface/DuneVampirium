extends CanvasLayer

# Shows every costed/manual Agent action left over after the free ones auto-fired
# (see GameState.build_agent_pending_actions/resolve_auto_actions) and lets the player
# trigger them one at a time, in any order — since an earlier trigger might grant a
# resource a later one needs. Visually in the same family as CardArrayPopup.

# Emitted whenever the prompt closes (Done button or the last item resolving) — lets
# board.gd finalize a Place/Reveal action's ActionLogEntry only once every pending
# trigger the player chose to fire has actually happened, not right after the free ones
# do. declined_items carries whichever PendingActions were still showing, untriggered
# (uses_so_far == 0), at close time — a Place caller can ignore the arg (Godot allows
# connecting a signal to a callable with fewer parameters); a Reveal caller uses it to
# record what the player chose NOT to trigger (CLAUDE.md 2026-10-20: declines are logged
# too, not just what happened).
signal closed(declined_items: Array)

var _items: Array[PendingAction] = []

var _overlay: ColorRect
var _panel: Panel
var _title_label: Label
var _scroll: ScrollContainer
var _row_vbox: VBoxContainer
var _done_button: Button

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
	_panel.anchor_left   = 0.15
	_panel.anchor_top    = 0.1
	_panel.anchor_right  = 0.85
	_panel.anchor_bottom = 0.9
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	vbox.offset_left   = 24.0
	vbox.offset_top    = 16.0
	vbox.offset_right  = -24.0
	vbox.offset_bottom = -16.0
	_panel.add_child(vbox)

	_title_label = Label.new()
	_title_label.text = "Choose an action to trigger"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(_title_label)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_AUTO
	vbox.add_child(_scroll)

	_row_vbox = VBoxContainer.new()
	_row_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_row_vbox.add_theme_constant_override("separation", 8)
	_scroll.add_child(_row_vbox)

	_done_button = Button.new()
	_done_button.text = "Done"
	_done_button.add_theme_font_size_override("font_size", 30)
	_done_button.custom_minimum_size = Vector2(0, 60)
	_done_button.pressed.connect(close)
	vbox.add_child(_done_button)

# Shows the prompt if there's anything to resolve. No-ops (does nothing, nothing left
# forfeited) if items is empty.
func show_pending(items: Array[PendingAction]) -> void:
	_items = items
	if _items.is_empty():
		return
	_rebuild_rows()
	visible = true

func close() -> void:
	visible = false
	var declined: Array = _items.filter(func(i: PendingAction): return i.uses_so_far == 0)
	_items.clear()
	for child in _row_vbox.get_children():
		child.queue_free()
	closed.emit(declined)

func _rebuild_rows() -> void:
	for child in _row_vbox.get_children():
		child.queue_free()

	if _items.is_empty():
		close()
		return

	for item: PendingAction in _items:
		_row_vbox.add_child(_build_row(item))

func _build_row(item: PendingAction) -> Control:
	var row := PanelContainer.new()

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	row.add_child(hbox)

	var label := Label.new()
	label.text = "%s — %s" % [item.source_name(), item.action_name]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 24)
	hbox.add_child(label)

	var icon_hbox := HBoxContainer.new()
	icon_hbox.custom_minimum_size = Vector2(200, 60)
	hbox.add_child(icon_hbox)
	ActionDisplay.populate_into(icon_hbox, item.effects, item.cost_type, item.cost_amount, GameEnums.RequirementType.NONE, 0, item.source)

	# Action-token cost / repeat-limit are a second cost dimension plain PendingAction
	# display doesn't otherwise show (ActionDisplay.populate_into only knows about
	# GameEnums.CostType resource costs) — append a plain-text summary rather than
	# building new icon assets for this (visual "juice" is explicitly deferred, see
	# CLAUDE.md's Future Considerations).
	if item.has_action_token_cost() or item.max_uses != 1:
		var meta_label := Label.new()
		var cost_part := (" · %d Action%s" % [item.action_token_cost, "" if item.action_token_cost == 1 else "s"]) if item.has_action_token_cost() else ""
		var uses_part := ""
		if item.max_uses == -1:
			uses_part = " · used %d (∞)" % item.uses_so_far
		elif item.max_uses != 1:
			uses_part = " · used %d/%d" % [item.uses_so_far, item.max_uses]
		meta_label.text = (cost_part + uses_part).strip_edges(true, false)
		meta_label.add_theme_font_size_override("font_size", 18)
		hbox.add_child(meta_label)

	var trigger_button := Button.new()
	trigger_button.text = "Trigger"
	trigger_button.add_theme_font_size_override("font_size", 22)
	trigger_button.custom_minimum_size = Vector2(140, 50)
	var p := GameState.current_player()
	var affordable := (not item.has_cost() or GameState.can_afford(p, {item.cost_type: item.cost_amount}))
	affordable = affordable and (not item.has_action_token_cost() or p.actions_remaining >= item.action_token_cost)
	trigger_button.disabled = not item.can_use_again() or not affordable
	trigger_button.pressed.connect(_on_trigger_pressed.bind(item))
	hbox.add_child(trigger_button)

	return row

func _on_trigger_pressed(item: PendingAction) -> void:
	if not GameState.try_trigger_pending(item):
		return
	# Repeatable items (max_uses > 1 or -1/unlimited) stay in the list, re-rendered with
	# their updated use count/affordability, until exhausted or the player closes —
	# unlike a plain one-shot Agent/Reveal item, which is erased the moment it fires.
	if not item.can_use_again():
		_items.erase(item)
	if _items.is_empty():
		close()
	else:
		_rebuild_rows()

func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event is InputEventKey:
		var ke := event as InputEventKey
		if ke.pressed and ke.keycode == KEY_ESCAPE:
			close()
			get_viewport().set_input_as_handled()
