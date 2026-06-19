class_name Card
extends Button

#Constant
const MINION_BOTTOM = preload("uid://bp5jfw8lkt0su")
const MINION_HIGHLIGHT = preload("uid://ijg8sosaoco8")
const MINION_NORMAL = preload("uid://dkl6uaeopqebv")
const MINION_TOP = preload("uid://c0dvkjiuc6ckk")
const PLAN_BOTTOM = preload("uid://cmh8lyje2xugq")
const PLAN_HIGHLIGHT = preload("uid://dbi88yeera2l8")
const PLAN_NORMAL = preload("uid://djf0c66c23ehw")
const PLAN_TOP = preload("uid://b8cece11fau6u")

const MOVE_DURATION: float = 0.25
const LONG_PRESS_DURATION: float = 0.5

#On Ready
@onready var outer_margin: MarginContainer = %MarginContainer
@onready var image_panel: Panel = %ImagePanel
@onready var image: TextureRect = %Image
@onready var pips_panel: Panel = %PipsPanel

@onready var actions_panel: Panel = %ActionsPanel
@onready var acquire_panel: Panel = %AcquirePanel
@onready var agent_panel: Panel = %AgentPanel
@onready var reveal_panel: Panel = %RevealPanel
@onready var discard_panel: Panel = %DiscardPanel
@onready var trash_panel: Panel = %TrashPanel

#Export

#Internal
var _sb_normal: StyleBoxFlat
var _sb_selected: StyleBoxFlat

# The gameplay data (Origin/Actions/Aspects/etc.) this card instance
# represents. Randomly assigned at _ready by the Plan/Minion subclass from
# its own pool of possible CardData resources. Setting it loads the matching
# artwork into the Image node.
var card_data: CardData:
	set(value):
		card_data = value
		_load_card_image()

var card_type: CardData.CardType = CardData.CardType.PLAN:
	set(value):
		card_type = value
		print_debug(card_type)

		# Automatically handle group registration based on the enum name
		for group in get_groups():
			remove_from_group(group)
		add_to_group("CARD")
		add_to_group(CardData.CardType.keys()[card_type])

		_setup_styleboxes.call_deferred()

# Where in the hand's HBoxContainer this card lives when it's not the
# selected one. Captured right before it's popped out into the holder so it
# can be put back in the same spot later.
var _origin_container: Node
var _origin_index: int = -1

# The global position _process continuously re-asserts while top_level is
# true. A tween animates this Vector2; _process applies it every frame so it
# wins out over any layout container trying to reposition us mid-flight.
var _target_global_position: Vector2
var _move_tween: Tween

# Guards the long-press timer below: cleared by button_up (or a fresh press)
# so a short tap doesn't trigger the zoomed-in view.
var _long_press_active: bool = false

# Timestamp (ms) of the last button_up, used to suppress the long-press timer
# when a second press arrives quickly enough to be a double-click.
var _last_button_up_ms: int = -1
const DOUBLE_CLICK_MS: int = 400

# Whether this card can currently be interacted with. Drives the stylebox
# (highlighted vs normal); selection no longer changes the stylebox.
var available: bool = false:
	set(value):
		if available == value:
			return
		available = value

		# Losing availability also loses selection, to preserve the
		# "selected implies available" invariant.
		if !available and selected:
			selected = false

		# Styleboxes aren't assigned until _setup_styleboxes runs; it will
		# apply the correct one itself once ready.
		if _sb_normal != null:
			_apply_availability_stylebox()

var selected: bool = false:
	set(value):
		if selected == value:
			return

		# Invariant: a selected card is always available. This guards the
		# setter itself (not just the click handler) so anything calling
		# select() programmatically can't violate it.
		if value and !available:
			return

		selected = value

		if value:
			_deselect_other_cards_of_my_type()
			_move_to_holder()
		else:
			_move_to_hand()

func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	card_type = card_type

	# TEMP: until turn/game logic decides this, availability is randomized
	# on startup.
	available = randf() < 0.5

	# Start with processing off since cards aren't selected by default
	set_process(false)

# While top_level is true (mid-flight to or from the holder), keep
# re-asserting the tweened target every frame. This is necessary because
# whichever Container we're currently parked in may try to resort/reposition
# us using its own layout coordinates, which we need to win out over.
func _process(_delta: float) -> void:
	if top_level and is_inside_tree():
		global_position = _target_global_position

# Finds this card's dedicated "selected card" slot, set up by Board.
func _get_holder() -> Control:
	var holder_group: String = "%s_HOLDER" % CardData.CardType.keys()[card_type]
	return get_tree().get_first_node_in_group(holder_group) as Control

# Pops the card out of its hand HBoxContainer and flies it into the holder
# for its type, remembering where it came from so it can return later.
func _move_to_holder() -> void:
	var holder: Control = _get_holder()
	if holder == null:
		push_warning("Card: no holder found for type %s" % CardData.CardType.keys()[card_type])
		return

	_origin_container = get_parent()
	_origin_index = get_index()

	var start_global: Vector2 = global_position
	_origin_container.remove_child(self)
	holder.add_child(self)
	position = Vector2.ZERO

	top_level = true
	set_process(true)
	_target_global_position = start_global
	global_position = start_global

	_fly_to(holder.global_position, _on_arrived_at_holder)

func _on_arrived_at_holder() -> void:
	# Guard against a deselect happening mid-flight.
	if selected:
		top_level = false
		set_process(false)
		position = Vector2.ZERO

# Pops the card out of the holder and flies it back to its original spot in
# the hand's HBoxContainer.
func _move_to_hand() -> void:
	if _origin_container == null:
		return

	var origin: Node = _origin_container
	var index: int = _origin_index
	_origin_container = null
	_origin_index = -1

	var start_global: Vector2 = global_position
	get_parent().remove_child(self)
	origin.add_child(self)
	origin.move_child(self, index)

	top_level = true
	set_process(true)

	# Hold steady at our starting position until we know where the
	# HBoxContainer actually wants to put us.
	_target_global_position = start_global
	global_position = start_global

	await get_tree().process_frame

	var target_global: Vector2 = origin.global_position + position
	_fly_to(target_global, _on_arrived_at_hand)

func _on_arrived_at_hand() -> void:
	# Guard against a reselect happening mid-flight.
	if !selected:
		top_level = false
		set_process(false)

func _fly_to(target_global: Vector2, on_finished: Callable = Callable()) -> void:
	if _move_tween:
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.tween_property(self, "_target_global_position", target_global, MOVE_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if on_finished.is_valid():
		_move_tween.finished.connect(on_finished)

func _deselect_other_cards_of_my_type() -> void:
	# Find our group name (e.g. "PLAN" or "MINION")
	var type_group_name: String = CardData.CardType.keys()[card_type]

	# Loop through all matching cards and safely deselect them if they aren't us
	for member in get_tree().get_nodes_in_group(type_group_name):
		if member != self and member is Card and member.selected:
			member.selected = false

func select() -> void:
	selected = true

func deselect() -> void:
	selected = false

func _setup_styleboxes() -> void:
	pass

# Loads the artwork matching card_data's resource file name (e.g.
# "feed.tres" -> "feed.png") from this card type's image folder. Falls back
# to a "default_<type>.png" in that same folder if no matching file exists.
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

func _apply_availability_stylebox() -> void:
	_set_stylebox(_sb_selected if available else _sb_normal)

func _set_stylebox(new_stylebox: StyleBoxFlat) -> void:
	add_theme_stylebox_override("normal", new_stylebox)
	add_theme_stylebox_override("hover", new_stylebox)
	add_theme_stylebox_override("focus", new_stylebox)
	add_theme_stylebox_override("pressed", new_stylebox)
	add_theme_stylebox_override("hover_pressed", new_stylebox)

func _on_button_down() -> void:
	print_debug("Card Size: %s" % [size])
	if available and !selected:
		selected = true

	var now_ms: int = Time.get_ticks_msec()
	var is_double_click: bool = _last_button_up_ms >= 0 and (now_ms - _last_button_up_ms) < DOUBLE_CLICK_MS
	if not is_double_click:
		_start_long_press_timer()

func _on_button_up() -> void:
	# A short tap releases before the timer fires, so this just prevents
	# that pending timer from doing anything when it does go off.
	_long_press_active = false
	_last_button_up_ms = Time.get_ticks_msec()

# Long-pressing works on any card - available or not, regardless of who it
# belongs to - since it's just for getting a closer look, not an action.
func _start_long_press_timer() -> void:
	_long_press_active = true
	get_tree().create_timer(LONG_PRESS_DURATION).timeout.connect(_on_long_press_timeout)

func _on_long_press_timeout() -> void:
	if _long_press_active:
		_long_press_active = false
		CardZoom.show_zoom_of(self)

# Called by card_scroller.gd when a drag has moved far enough to trigger a
# hand scroll, so a long-press that was just starting (because the player's
# initial touch happened to land on a card) doesn't pop up a zoom view out
# from under a scroll gesture.
func cancel_long_press() -> void:
	_long_press_active = false

# Returns the PackedScene to instantiate for this card's long-press zoom
# popup. Overridden by Minion/Plan to point at their *Zoom scene; base Card
# has none.
func _get_zoom_scene() -> PackedScene:
	return null

# Resizes this card to fill the screen vertically while preserving the given
# width/height aspect ratio. Used by the *Zoom variants (MinionZoom,
# PlanZoom) to blow themselves up to a large, readable size - since the
# internal layout is all Containers/anchors, growing the root size like this
# makes every child resize right along with it, staying crisp rather than
# stretching a small captured texture.
#
# card.tscn's outer MarginContainer uses this on all four sides, matching
# the root stylebox's border_width so the inner content starts right at the
# inside edge of the border. _make_scaled_stylebox grows that border by
# _size_scale_factor, so the margin needs to grow by the same amount to keep
# matching it.
const OUTER_MARGIN_BASE: int = 8

# image_panel is the one exception: Minion/Plan give it a fixed pixel height
# (so it looks right at hand-sized CARD_SIZE), which doesn't grow on its own
# just because the root got bigger. Rescale it - and pips_panel's minimum
# height, and the outer margin - by the same factor the card as a whole just
# grew by, so everything keeps the same proportion of the card at any size.
func _resize_to_fill_screen_vertically(aspect_ratio: float) -> void:
	var viewport_height: float = get_viewport().get_visible_rect().size.y
	var target_size: Vector2 = Vector2(viewport_height * aspect_ratio, viewport_height)
	_size_scale_factor = target_size.y / size.y

	size = target_size
	custom_minimum_size = target_size

	if image_panel:
		image_panel.custom_minimum_size.y *= _size_scale_factor

	if pips_panel:
		pips_panel.custom_minimum_size.y *= _size_scale_factor

	if outer_margin:
		var scaled_margin: int = roundi(OUTER_MARGIN_BASE * _size_scale_factor)
		outer_margin.add_theme_constant_override("margin_left", scaled_margin)
		outer_margin.add_theme_constant_override("margin_top", scaled_margin)
		outer_margin.add_theme_constant_override("margin_right", scaled_margin)
		outer_margin.add_theme_constant_override("margin_bottom", scaled_margin)

# How much bigger (or smaller) than CARD_SIZE this instance currently is.
# Set by _resize_to_fill_screen_vertically; stays 1.0 for ordinary
# hand-sized cards. The *Zoom variants use this to scale up corner radii and
# border widths to match, via _make_scaled_stylebox below - otherwise a
# stylebox tuned to look right at CARD_SIZE (e.g. a corner radius just big
# enough to clamp into a half-circle cap) stops looking right once the card
# is blown up much bigger.
var _size_scale_factor: float = 1.0

# Returns a copy of base with its corner radii and border widths scaled by
# _size_scale_factor, so a stylebox designed for hand-sized CARD_SIZE still
# looks correctly proportioned on a much bigger zoomed-in card.
func _make_scaled_stylebox(base: StyleBoxFlat) -> StyleBoxFlat:
	var scaled: StyleBoxFlat = base.duplicate()
	if _size_scale_factor == 1.0:
		return scaled

	scaled.corner_radius_top_left = roundi(base.corner_radius_top_left * _size_scale_factor)
	scaled.corner_radius_top_right = roundi(base.corner_radius_top_right * _size_scale_factor)
	scaled.corner_radius_bottom_left = roundi(base.corner_radius_bottom_left * _size_scale_factor)
	scaled.corner_radius_bottom_right = roundi(base.corner_radius_bottom_right * _size_scale_factor)
	scaled.border_width_left = roundi(base.border_width_left * _size_scale_factor)
	scaled.border_width_top = roundi(base.border_width_top * _size_scale_factor)
	scaled.border_width_right = roundi(base.border_width_right * _size_scale_factor)
	scaled.border_width_bottom = roundi(base.border_width_bottom * _size_scale_factor)

	# StyleBoxFlat approximates rounded corners with a fixed number of
	# straight segments (corner_detail). That count was fine for the small
	# radii at hand-sized CARD_SIZE, but the same segment count stretched
	# around a much bigger curve is what's producing the faceted/jagged
	# diagonal edges - so use the max for any corner that's actually rounded.
	if base.corner_radius_top_left > 0 or base.corner_radius_top_right > 0 \
			or base.corner_radius_bottom_left > 0 or base.corner_radius_bottom_right > 0:
		scaled.corner_detail = 20

	return scaled
