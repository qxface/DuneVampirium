class_name Space
extends Button

const LONG_PRESS_DURATION: float = 0.5

@onready var image_panel: Panel = %ImagePanel
@onready var requirements_panel: Panel = %RequirementsPanel
@onready var requirements_container: VBoxContainer = %RequirementsContainer
@onready var image: TextureRect = %SpaceImage
@onready var future_panel: Panel = %FuturePanel

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

var _sb_unavailable: StyleBoxFlat = preload("res://assets/styleboxes/space_unavailable.tres")
var _sb_available:   StyleBoxFlat = preload("res://assets/styleboxes/space_available.tres")
var _sb_selected:    StyleBoxFlat = preload("res://assets/styleboxes/space_selected.tres")

var _long_press_active: bool = false
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

# --- Content ---

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
		elif available:
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
