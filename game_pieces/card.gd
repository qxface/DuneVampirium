class_name Card
extends Button

const MOVE_DURATION: float = 0.25
const LONG_PRESS_DURATION: float = 0.5

const HEIGHT: int = 250
const WIDTH: int = 175

#On Ready
@onready var outer_margin: MarginContainer = %MarginContainer
@onready var image_panel: Panel = %ImagePanel
@onready var image: TextureRect = %Image
@onready var pips_panel: Panel = %PipsPanel

@onready var action_pips: HBoxContainer = %ActionPipsContainer
@onready var origin_pips: HBoxContainer = %OriginPipsContainer
@onready var trait_pips: HBoxContainer = %TraitPipsContainer

@onready var actions_panel: Panel = %ActionsPanel
@onready var acquire_panel: Panel = %AcquirePanel
@onready var agent_panel: Panel = %AgentPanel
@onready var reveal_panel: Panel = %RevealPanel
@onready var discard_panel: Panel = %DiscardPanel
@onready var trash_panel: Panel = %TrashPanel

@onready var name_panel: Panel = %NamePanel
@onready var name_label: Label = %NameLabel

var _sb_normal : StyleBoxFlat = null
var _sb_selected : StyleBoxFlat = null

var card_data: CardData:
	set(value):
		card_data = value
		_load_card_image()
		if is_node_ready():
			_update_pips()
			_update_actions()
			name_label.text = card_data.card_name

var card_type: CardData.CardType = CardData.CardType.PLAN:
	set(value):
		card_type = value
		print_debug(card_type)
		for group in get_groups():
			remove_from_group(group)
		add_to_group("CARD")
		add_to_group(CardData.CardType.keys()[card_type])

var _origin_container: Node
var _origin_index: int = -1

var _target_global_position: Vector2
var _move_tween: Tween

var _long_press_active: bool = false
var _was_selected_on_press: bool = false

var _last_button_up_ms: int = -1
const DOUBLE_CLICK_MS: int = 400

var can_select: bool = true

var selected: bool = false:
	set(value):
		if value and not can_select:
			return
		if selected == value:
			return
		selected = value
		_apply_stylebox()
		if value:
			_move_to_holder()
		else:
			_move_to_hand()
		Availability.update.call_deferred()

func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	card_type = card_type
	_apply_stylebox.call_deferred()
	_ensure_icon_containers()
	if card_data:
		_update_pips()
		_update_actions()
	set_process(false)

func _ensure_icon_containers() -> void:
	for panel: Panel in [acquire_panel, agent_panel, reveal_panel, discard_panel, trash_panel]:
		if panel.get_node_or_null("IconMargin") != null:
			continue
		var margin := MarginContainer.new()
		margin.name = "IconMargin"
		margin.add_theme_constant_override("margin_left", 4)
		margin.add_theme_constant_override("margin_top", 4)
		margin.add_theme_constant_override("margin_right", 4)
		margin.add_theme_constant_override("margin_bottom", 4)
		panel.add_child(margin)
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var hbox := HBoxContainer.new()
		hbox.name = "IconContainer"
		hbox.add_theme_constant_override("separation", 4)
		margin.add_child(hbox)

func _process(_delta: float) -> void:
	if top_level and is_inside_tree():
		global_position = _target_global_position

func _get_holder() -> Control:
	var holder_group: String = "%s_HOLDER" % CardData.CardType.keys()[card_type]
	return get_tree().get_first_node_in_group(holder_group) as Control

func _move_to_holder() -> void:
	var holder: Control = _get_holder()
	if holder == null:
		push_warning("Card: no holder found for type %s" % CardData.CardType.keys()[card_type])
		return

	_origin_container = get_parent()
	_origin_index = get_index()

	var start_global: Vector2 = global_position

	get_parent().remove_child(self)
	holder.add_child(self)
	holder.move_child(self, 0)

	modulate.a = 0.0
	top_level = false

	_request_width_update()

	await get_tree().process_frame

	var target_global: Vector2 = global_position
	modulate.a = 1.0

	top_level = true
	_target_global_position = start_global
	global_position = start_global
	set_process(true)
	_fly_to(target_global, _on_arrived_at_holder)

func _on_arrived_at_holder() -> void:
	if selected:
		set_process(false)
		var local_pos: Vector2 = _target_global_position - get_parent().global_position
		top_level = false
		position = local_pos

func _move_to_hand() -> void:
	if _origin_container == null:
		return

	var origin: Node = _origin_container
	var index: int = _origin_index
	_origin_container = null
	_origin_index = -1

	if _move_tween:
		_move_tween.kill()
	set_process(false)

	var start_global: Vector2 = global_position

	get_parent().remove_child(self)
	origin.add_child(self)
	origin.move_child(self, index)

	modulate.a = 0.0
	top_level = false

	_request_width_update()

	await get_tree().process_frame

	var target_global: Vector2 = global_position
	modulate.a = 1.0

	top_level = true
	_target_global_position = start_global
	global_position = start_global
	set_process(true)
	_fly_to(target_global, _on_arrived_at_hand)

func _on_arrived_at_hand() -> void:
	if !selected:
		set_process(false)
		var local_pos: Vector2 = _target_global_position - get_parent().global_position
		top_level = false
		position = local_pos

func _fly_to(target_global: Vector2, on_finished: Callable = Callable()) -> void:
	if _move_tween:
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.tween_property(self, "_target_global_position", target_global, MOVE_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if on_finished.is_valid():
		_move_tween.finished.connect(on_finished)

func _request_width_update() -> void:
	var board = get_tree().get_first_node_in_group("BOARD")
	if board:
		board._update_hand_widths.call_deferred()

func select() -> void:
	selected = true

func deselect() -> void:
	selected = false

func _load_card_image() -> void:
	if image == null or card_data == null:
		return
	var type_keyword: String = CardData.CardType.keys()[card_type].to_lower()
	var folder: String = "res://assets/images/cards/%ss" % type_keyword
	var base_name: String = card_data.resource_path.get_file().get_basename()
	var path: String = "%s/%s.png" % [folder, base_name]
	if not ResourceLoader.exists(path):
		path = "%s/default_%s.png" % [folder, type_keyword]
	if ResourceLoader.exists(path):
		image.texture = load(path)
	else:
		push_warning("Card: no artwork found for '%s' (tried %s)" % [base_name, path])

func _update_actions() -> void:
	if card_data == null:
		return
	acquire_panel.visible = card_data.acquire_action
	agent_panel.visible   = card_data.agent_action
	reveal_panel.visible  = card_data.reveal_action
	discard_panel.visible = card_data.discard_action
	trash_panel.visible   = card_data.trash_action
	_populate_action_icons()

func _populate_action_icons() -> void:
	pass

func _update_pips() -> void:
	if card_data == null:
		return
	if action_pips == null or origin_pips == null or trait_pips == null:
		return

	action_pips.get_child(0).visible = card_data.fight
	action_pips.get_child(1).visible = card_data.hunt
	action_pips.get_child(2).visible = card_data.negotiate

	origin_pips.get_child(0).visible = card_data.vampire
	origin_pips.get_child(1).visible = card_data.supernatural
	origin_pips.get_child(2).visible = card_data.human

	trait_pips.get_child(0).visible = card_data.insane
	trait_pips.get_child(1).visible = card_data.hideous
	trait_pips.get_child(2).visible = card_data.arcane

func _apply_stylebox() -> void:
	_set_stylebox(_sb_selected if selected else _sb_normal)

func _set_stylebox(new_stylebox: StyleBoxFlat) -> void:
	add_theme_stylebox_override("normal", new_stylebox)
	add_theme_stylebox_override("hover", new_stylebox)
	add_theme_stylebox_override("focus", new_stylebox)
	add_theme_stylebox_override("pressed", new_stylebox)
	add_theme_stylebox_override("hover_pressed", new_stylebox)

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
		else:
			selected = true
	_long_press_active = false
	_last_button_up_ms = Time.get_ticks_msec()

func _start_long_press_timer() -> void:
	_long_press_active = true
	get_tree().create_timer(LONG_PRESS_DURATION).timeout.connect(_on_long_press_timeout)

func _on_long_press_timeout() -> void:
	if _long_press_active:
		_long_press_active = false
		CardZoom.show_zoom_of(self)

func cancel_long_press() -> void:
	_long_press_active = false

func _get_zoom_scene() -> PackedScene:
	return null
