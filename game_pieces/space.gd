class_name Space
extends Button

const LONG_PRESS_DURATION: float = 0.5

# Base border widths and corner radii at the default 250×125 size.
const BASE_BORDER: int = 4
const BASE_CORNER: int = 6

# Border colours for each state.
const COLOR_UNAVAILABLE: Color = Color(0.0,  0.0,  0.0,  1.0)
const COLOR_AVAILABLE:   Color = Color(1.0,  1.0,  1.0,  1.0)
const COLOR_SELECTED:    Color = Color(0.65, 0.04, 0.04, 1.0)
const BG_COLOR:          Color = Color(0.12, 0.10, 0.08, 1.0)

@onready var requirements_panel: Panel = %RequirementsPanel
@onready var requirements_container: VBoxContainer = %RequirementsContainer
@onready var image: TextureRect = %SpaceImage
@onready var future_panel: Panel = %FuturePanel

# Base panel sizes at the default 250×125 scale.
# RequirementsPanel: 4 icons × 16px + 8px side margins = 72px → 76px with breathing room.
# FuturePanel: 1 icon (16px) + 12px top/bottom margin each = 40px.
const BASE_REQS_WIDTH: int = 76
const BASE_FUTURE_HEIGHT: int = 40

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
		if selected == value:
			return
		selected = value
		if value:
			_deselect_other_spaces()
		_apply_stylebox()
		Availability.update.call_deferred()

# Scale factor relative to the default 250×125 size; overridden by SpaceZoom.
var _size_scale_factor: float = 1.0

var _sb_unavailable: StyleBoxFlat
var _sb_available: StyleBoxFlat
var _sb_selected: StyleBoxFlat

var _long_press_active: bool = false
var _was_selected_on_press: bool = false
var _last_button_up_ms: int = -1
const DOUBLE_CLICK_MS: int = 400

func _ready() -> void:
	add_to_group("SPACE")
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	custom_minimum_size.x = 250
	custom_minimum_size.y = 125
	_setup_styleboxes.call_deferred()
	if space_data:
		_load_space()

func _load_space() -> void:
	_load_image()
	_populate_requirements()

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

	var row_height: int = roundi(16.0 * _size_scale_factor)

	for i in space_data.requirement_clauses.size():
		var clause: SpaceRequirement = space_data.requirement_clauses[i]
		if clause == null:
			continue

		if i > 0:
			var sep := HSeparator.new()
			requirements_container.add_child(sep)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 0)
		row.custom_minimum_size = Vector2(0, row_height)

		if clause.origin != CardData.OriginType.NONE:
			_add_icon(row, _origin_icon_path(clause.origin))
		if clause.action != SpaceRequirement.ActionRequirement.NONE:
			_add_icon(row, _action_icon_path(clause.action))
		if clause.aspect != SpaceRequirement.AspectRequirement.NONE:
			_add_icon(row, _aspect_icon_path(clause.aspect))

		requirements_container.add_child(row)

func _add_icon(container: HBoxContainer, icon_path: String) -> void:
	if icon_path.is_empty() or not ResourceLoader.exists(icon_path):
		return
	var icon := TextureRect.new()
	icon.texture = load(icon_path)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	container.add_child(icon)

func _origin_icon_path(origin: CardData.OriginType) -> String:
	match origin:
		CardData.OriginType.VAMPIRE:      return "res://assets/icons/origins/vampire.png"
		CardData.OriginType.SUPERNATURAL: return "res://assets/icons/origins/supernatural.png"
		CardData.OriginType.HUMAN:        return "res://assets/icons/origins/human.png"
	return ""

func _action_icon_path(action: SpaceRequirement.ActionRequirement) -> String:
	match action:
		SpaceRequirement.ActionRequirement.POLITICS: return "res://assets/icons/actions/intrigue.png"
		SpaceRequirement.ActionRequirement.HUNT:     return "res://assets/icons/actions/hunting.png"
		SpaceRequirement.ActionRequirement.BATTLE:   return "res://assets/icons/actions/battle.png"
	return ""

func _aspect_icon_path(aspect: SpaceRequirement.AspectRequirement) -> String:
	match aspect:
		SpaceRequirement.AspectRequirement.MADNESS:   return "res://assets/icons/aspects/madness.png"
		SpaceRequirement.AspectRequirement.HIDEOUS:   return "res://assets/icons/aspects/hideous.png"
		SpaceRequirement.AspectRequirement.SORCEROUS: return "res://assets/icons/aspects/sorcerous.png"
	return ""

# --- Styling ---

func _setup_styleboxes() -> void:
	if not is_node_ready():
		await get_tree().process_frame
	var border: int = roundi(BASE_BORDER * _size_scale_factor)
	var corner: int = roundi(BASE_CORNER * _size_scale_factor)
	_sb_unavailable = _make_stylebox(COLOR_UNAVAILABLE, border, corner)
	_sb_available   = _make_stylebox(COLOR_AVAILABLE,   border, corner)
	_sb_selected    = _make_stylebox(COLOR_SELECTED,    border, corner)
	_apply_stylebox()
	requirements_panel.custom_minimum_size.x = roundi(BASE_REQS_WIDTH * _size_scale_factor)
	future_panel.custom_minimum_size.y = roundi(BASE_FUTURE_HEIGHT * _size_scale_factor)

func _make_stylebox(border_color: Color, border: int, corner: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = BG_COLOR
	sb.border_width_left   = border
	sb.border_width_top    = border
	sb.border_width_right  = border
	sb.border_width_bottom = border
	sb.border_color = border_color
	sb.corner_radius_top_left     = corner
	sb.corner_radius_top_right    = corner
	sb.corner_radius_bottom_right = corner
	sb.corner_radius_bottom_left  = corner
	return sb

func _apply_stylebox() -> void:
	if _sb_unavailable == null:
		return
	var sb: StyleBoxFlat = _sb_unavailable
	if selected:
		sb = _sb_selected
	elif available:
		sb = _sb_available
	add_theme_stylebox_override("normal",  sb)
	add_theme_stylebox_override("hover",   sb)
	add_theme_stylebox_override("pressed", sb)
	add_theme_stylebox_override("focus",   sb)

func _deselect_other_spaces() -> void:
	for node in get_tree().get_nodes_in_group("SPACE"):
		if node != self and node is Space and node.selected:
			node.selected = false

# --- Input ---

func _on_button_down() -> void:
	_was_selected_on_press = selected
	if not selected:
		selected = true
	var now_ms: int = Time.get_ticks_msec()
	var is_double_click: bool = _last_button_up_ms >= 0 and (now_ms - _last_button_up_ms) < DOUBLE_CLICK_MS
	if not is_double_click:
		_start_long_press_timer()

func _on_button_up() -> void:
	# Deselect only on a short press of an already-selected space.
	# If _long_press_active is false here the timer already fired (zoom), so skip.
	if _was_selected_on_press and _long_press_active:
		selected = false
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
