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

#On Ready
@onready var image_panel: Panel = %ImagePanel
@onready var image: TextureRect = %Image

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
