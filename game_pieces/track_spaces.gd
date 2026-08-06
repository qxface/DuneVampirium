class_name TrackSpaces
extends Panel

# One faction's Track paired with up to 3 of its Spaces, laid out side-by-side.
# faction_name/low_space/high_space/third_space are forwarded to the inner Track/Space
# nodes — set per-instance in the Inspector. A Space slot with no SpaceData assigned is
# hidden entirely (see _apply_space) rather than shown as an unusable blank placeholder.
#
# Spaces fill the column from the BOTTOM up: low_space (the simple, no-cost one) goes
# in the bottom-most slot, high_space (the costed, more powerful one) sits above it, and
# third_space — currently unused for all Factions — is the top-most, so a lone low_space
# ends up bottom-aligned and each added space stacks on top of the previous one. The
# VBoxContainer's own child order is fixed top-to-bottom as Space/Space2/Space3, so this
# mapping is inverted from that (Space3 = bottom = low_space, Space = top = third_space).

@export var faction_name: String = "":
	set(value):
		faction_name = value
		if is_node_ready():
			track.faction_name = value

@export var low_space: SpaceData = null:
	set(value):
		low_space = value
		if is_node_ready():
			_apply_space(_space3, value)

@export var high_space: SpaceData = null:
	set(value):
		high_space = value
		if is_node_ready():
			_apply_space(_space2, value)

@export var third_space: SpaceData = null:
	set(value):
		third_space = value
		if is_node_ready():
			_apply_space(_space, value)

# Public so board.gd can reach it directly for Track.refresh() — the Track nodes are no
# longer direct unique-name children of board.tscn now that they're nested in here.
@onready var track: Track = $MarginContainer/HBoxContainer/Track
@onready var _space: Space = $MarginContainer/HBoxContainer/VBoxContainer/Space
@onready var _space2: Space = $MarginContainer/HBoxContainer/VBoxContainer/Space2
@onready var _space3: Space = $MarginContainer/HBoxContainer/VBoxContainer/Space3

func _ready() -> void:
	track.faction_name = faction_name
	_apply_space(_space3, low_space)
	_apply_space(_space2, high_space)
	_apply_space(_space, third_space)

# A slot with no SpaceData assigned is hidden entirely rather than shown as a blank
# placeholder — an empty Space has no space_data for anything (image, requirements,
# long-press zoom) to read, which is what was throwing on long-press.
func _apply_space(space: Space, data: SpaceData) -> void:
	space.visible = data != null
	if data != null:
		space.space_data = data
