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

# Internal tracking to remember each card's spot in the HBox row
var _saved_container_position: Vector2

var selected: bool = false:
	set(value):
		if selected == value: 
			return
			
		selected = value
		
		if value:
			_deselect_other_cards_of_my_type()
			_set_stylebox(_sb_selected)
			
			# 1. Save its local layout coordinates before lifting it up
			_saved_container_position = position
			top_level = true
			
			# 2. Enable processing so it tracks container movement
			set_process(true)
		else:
			_set_stylebox(_sb_normal)
			
			# 3. Stop tracking movement and hand control back to HBoxContainer
			set_process(false)
			top_level = false
			position = _saved_container_position

func _ready() -> void:
	button_down.connect(_on_button_down)
	card_type = card_type
	
	# Start with processing off since cards aren't selected by default
	set_process(false)

# Dynamically track parent scrolling position while top_level is true
func _process(_delta: float) -> void:
	if selected and is_inside_tree():
		var parent = get_parent() as Control
		if parent:
			# Reconstruct absolute global position based on parent container's live screen coordinates
			global_position.x = parent.global_position.x + _saved_container_position.x
			global_position.y = parent.global_position.y + _saved_container_position.y - 100

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

func _set_stylebox(new_stylebox: StyleBoxFlat) -> void:
	add_theme_stylebox_override("normal", new_stylebox)
	add_theme_stylebox_override("hover", new_stylebox)
	add_theme_stylebox_override("focus", new_stylebox)
	add_theme_stylebox_override("pressed", new_stylebox)
	add_theme_stylebox_override("hover_pressed", new_stylebox)

func _on_button_down() -> void:
	print_debug("Card Size: %s" % [size])
	if !selected:
		selected = true
