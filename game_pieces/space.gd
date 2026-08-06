class_name Space
extends Button

signal recall_selection_changed

const LONG_PRESS_DURATION: float = 0.5
const _RECALL_SELECTED_MODULATE: Color = Color(0.4, 1.0, 0.4)
const _RECALL_UNSELECTED_MODULATE: Color = Color(1.0, 1.0, 1.0)

@onready var image_panel: Panel = %ImagePanel
@onready var requirements_panel: Panel = %RequirementsPanel
@onready var requirements_container: VBoxContainer = %RequirementsContainer
@onready var image: TextureRect = %SpaceImage
@onready var action_panel: Panel = %ActionPanel
@onready var action_container: HBoxContainer = %ActionContainer
@onready var name_label: Label = %NameLabel

@export var space_data: SpaceData:
	set(value):
		space_data = value
		if is_node_ready():
			_load_space()

var available: bool = false:
	set(value):
		available = value
		_apply_stylebox()

var selected: bool = false:
	set(value):
		if value and is_occupied:
			return
		if selected == value:
			return
		selected = value
		if value:
			_deselect_other_spaces()
		_apply_stylebox()
		Availability.update.call_deferred()

# _sb_base is the space's resting look — background + border, border tinted to the
# space's faction/category color if it has one (see _apply_faction_border()). It no
# longer varies with available/selected state; that's now shown via modulate (dim vs
# full-bright, see _apply_dim()) and, for selected, a glow (see _sb_selected_glow).
var _sb_base: StyleBoxFlat = preload("res://assets/styleboxes/space_unavailable.tres")
# Built once from _sb_base (see _rebuild_selected_glow()) — same bg/border, plus a
# soft StyleBoxFlat shadow used as a glowing halo. No shader needed: StyleBoxFlat's
# built-in shadow_color/shadow_size already renders a soft blurred glow that respects
# the box's corner radius.
var _sb_selected_glow: StyleBoxFlat = null

const _DIM_MODULATE: Color = Color(0.45, 0.45, 0.45, 0.55)
const _BRIGHT_MODULATE: Color = Color(1.0, 1.0, 1.0, 1.0)
const _GLOW_COLOR: Color = Color(1.0, 1.0, 1.0, 0.65)
const _GLOW_SIZE: int = 14

var _meeple_overlay: Control = null
var _placed_card_datas: Array[CardData] = []
var _meeple_long_press_active: bool = false
var _long_press_active: bool = false

# Set by Board when the Recall action is being composed; while true, clicking
# the meeple toggles recall_selected instead of doing nothing on a short click.
var recalling: bool = false:
	set(value):
		recalling = value
		if not value:
			recall_selected = false

var recall_selected: bool = false:
	set(value):
		if recall_selected == value:
			return
		recall_selected = value
		if _meeple_overlay:
			_meeple_overlay.modulate = _RECALL_SELECTED_MODULATE if value else _RECALL_UNSELECTED_MODULATE
		recall_selection_changed.emit()

var is_occupied: bool:
	get: return _meeple_overlay != null
var _was_selected_on_press: bool = false
var _last_button_up_ms: int = -1
const DOUBLE_CLICK_MS: int = 400

func _ready() -> void:
	add_to_group("SPACE")
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	if space_data:
		_load_space()

func _apply_stylebox() -> void:
	if _sb_base == null:
		return
	var sb: StyleBoxFlat = _sb_selected_glow if (selected and _sb_selected_glow != null) else _sb_base
	add_theme_stylebox_override("normal",  sb)
	add_theme_stylebox_override("hover",   sb)
	add_theme_stylebox_override("pressed", sb)
	add_theme_stylebox_override("focus",   sb)
	_apply_dim()

# Unavailable spaces are dimmed and slightly transparent; available (including
# selected, which is always a subset of available) are full-bright, full-alpha.
func _apply_dim() -> void:
	modulate = _BRIGHT_MODULATE if (available or selected) else _DIM_MODULATE

func _deselect_other_spaces() -> void:
	for node in get_tree().get_nodes_in_group("SPACE"):
		if node != self and node is Space and node.selected:
			node.selected = false

# --- Content ---

func _load_space() -> void:
	_load_image()
	name_label.text = space_data.space_name
	_populate_requirements()
	action_panel.visible = space_data.agent_action
	ActionDisplay.populate_into(action_container, space_data.agent_effects, space_data.agent_cost, space_data.agent_cost_amount, space_data.agent_requirement, space_data.agent_requirement_amount)
	_apply_faction_border()

# A Space "belongs" to whichever faction one of its agent_effects advances (see
# FactionTrackData.track_color) — not a separate field, since the effect data is
# already the single source of truth for which faction a Space brings into the game.
# The border color is now purely identity/category — it no longer changes with
# available/selected state (see _apply_dim()/_rebuild_selected_glow() for those).
# Duplicates the shared stylebox into a per-instance copy before tinting it, since
# PackedScene sub-resources (the preloaded _sb_* StyleBoxFlats) are shared across every
# Space instance by default.
func _apply_faction_border() -> void:
	_sb_base = _sb_base.duplicate()
	var color: Variant = _derive_faction_color()
	if color != null:
		_sb_base.border_color = color
	_rebuild_selected_glow()
	_apply_stylebox()

# Rebuilds the selected-glow stylebox from the current _sb_base (so it always matches
# the space's identity border color) plus a soft StyleBoxFlat shadow — the "glowing
# transparent halo" around a selected space.
func _rebuild_selected_glow() -> void:
	_sb_selected_glow = _sb_base.duplicate()
	_sb_selected_glow.shadow_color = _GLOW_COLOR
	_sb_selected_glow.shadow_size = _GLOW_SIZE
	_sb_selected_glow.shadow_offset = Vector2.ZERO

func _derive_faction_color() -> Variant:
	for effect: Effect in space_data.agent_effects:
		if effect is AdvanceFactionTrack:
			var track: FactionTrackData = GameState.faction_tracks.get((effect as AdvanceFactionTrack).faction_name, null)
			if track != null:
				return track.track_color
	return null

func _load_image() -> void:
	if image == null or space_data == null:
		return
	var base_name: String = space_data.resource_path.get_file().get_basename()
	var path: String = "res://assets/images/cards/spaces/%s.png" % base_name
	if not ResourceLoader.exists(path):
		path = "res://assets/images/cards/spaces/default_space.png"
	if ResourceLoader.exists(path):
		image.texture = load(path)

func _populate_requirements() -> void:
	if requirements_container == null or space_data == null:
		return
	for child in requirements_container.get_children():
		child.queue_free()

	for i in space_data.requirement_clauses.size():
		var clause: SpaceRequirement = space_data.requirement_clauses[i]
		if clause == null:
			continue

		if i > 0:
			requirements_container.add_child(HSeparator.new())

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 0)

		if clause.vampire:
			_add_icon(row, "res://assets/icons/origins/vampire.png")
		if clause.supernatural:
			_add_icon(row, "res://assets/icons/origins/supernatural.png")
		if clause.human:
			_add_icon(row, "res://assets/icons/origins/human.png")
		if clause.action != SpaceRequirement.ActionRequirement.NONE:
			_add_icon(row, _action_icon_path(clause.action))
		if clause.aspect != SpaceRequirement.AspectRequirement.NONE:
			_add_icon(row, _aspect_icon_path(clause.aspect))
		if clause.requirement_type != GameEnums.RequirementType.NONE:
			ActionDisplay.add_typed_icon(row, GameEnums.requirement_icon_path(clause.requirement_type), clause.requirement_amount, true)
		if clause.cost_type != GameEnums.CostType.NONE:
			ActionDisplay.add_typed_icon(row, GameEnums.cost_icon_path(clause.cost_type), clause.cost_amount, false)

		requirements_container.add_child(row)

func _add_icon(container: HBoxContainer, icon_path: String) -> void:
	if icon_path.is_empty() or not ResourceLoader.exists(icon_path):
		return
	var icon := TextureRect.new()
	icon.texture = load(icon_path)
	icon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(icon)

func _action_icon_path(action: SpaceRequirement.ActionRequirement) -> String:
	match action:
		SpaceRequirement.ActionRequirement.NEGOTIATE: return "res://assets/icons/actions/negotiate.png"
		SpaceRequirement.ActionRequirement.HUNT:      return "res://assets/icons/actions/hunting.png"
		SpaceRequirement.ActionRequirement.FIGHT:     return "res://assets/icons/actions/fight.png"
	return ""

func _aspect_icon_path(aspect: SpaceRequirement.AspectRequirement) -> String:
	match aspect:
		SpaceRequirement.AspectRequirement.INSANE:    return "res://assets/icons/aspects/insane.png"
		SpaceRequirement.AspectRequirement.HIDEOUS:   return "res://assets/icons/aspects/hideous.png"
		SpaceRequirement.AspectRequirement.ARCANE:    return "res://assets/icons/aspects/arcane.png"
	return ""

# --- Input ---

func _on_button_down() -> void:
	_was_selected_on_press = selected
	var now_ms: int = Time.get_ticks_msec()
	var is_double_click: bool = _last_button_up_ms >= 0 and (now_ms - _last_button_up_ms) < DOUBLE_CLICK_MS
	if not is_double_click:
		_start_long_press_timer()

func _on_button_up() -> void:
	if _long_press_active:
		if _was_selected_on_press:
			selected = false
		elif available and not is_occupied:
			selected = true
	_long_press_active = false
	_last_button_up_ms = Time.get_ticks_msec()

func _start_long_press_timer() -> void:
	_long_press_active = true
	get_tree().create_timer(LONG_PRESS_DURATION).timeout.connect(_on_long_press_timeout)

func _on_long_press_timeout() -> void:
	if _long_press_active:
		_long_press_active = false
		SpaceZoom.show_zoom_of(self)

func cancel_long_press() -> void:
	_long_press_active = false

# Adds or replaces the meeple icon on this space.
# card_datas: all CardData for the minions placed here.
# The meeple is anchored so its center sits at the space's upper-left corner.
func add_minion_meeple(card_datas: Array) -> void:
	if _meeple_overlay:
		_meeple_overlay.queue_free()

	_placed_card_datas.clear()
	for d in card_datas:
		_placed_card_datas.append(d)

	_meeple_overlay = Control.new()
	_meeple_overlay.size = Vector2(75.0, 50.0)
	_meeple_overlay.position = Vector2(-18.0, -25.0)
	_meeple_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_meeple_overlay.z_index = 1
	add_child(_meeple_overlay)

	var icon := TextureRect.new()
	icon.texture = load("res://assets/icons/minions/minion.png")
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_meeple_overlay.add_child(icon)

	if card_datas.size() > 1:
		var count_label := Label.new()
		count_label.text = "×%d" % card_datas.size()
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_meeple_overlay.add_child(count_label)

	_meeple_overlay.gui_input.connect(_on_meeple_input)

func clear_meeple() -> void:
	if _meeple_overlay:
		_meeple_overlay.queue_free()
		_meeple_overlay = null
	_placed_card_datas.clear()
	recall_selected = false

func placed_minions() -> Array[CardData]:
	return _placed_card_datas.duplicate()

func _on_meeple_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT:
		return
	get_viewport().set_input_as_handled()
	if mb.pressed:
		_meeple_long_press_active = true
		get_tree().create_timer(LONG_PRESS_DURATION).timeout.connect(_on_meeple_long_press_timeout)
	else:
		if _meeple_long_press_active and recalling:
			recall_selected = not recall_selected
		_meeple_long_press_active = false

func _on_meeple_long_press_timeout() -> void:
	if _meeple_long_press_active:
		_meeple_long_press_active = false
		var title: String = "Minions at %s" % (space_data.space_name if space_data else "Space")
		CardArrayPopup.show_cards(_placed_card_datas, title)
