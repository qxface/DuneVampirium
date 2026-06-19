class_name Minion
extends Card

const CARD_SIZE: Vector2 = Vector2(175, 250)

const DATA_OPTIONS: Array[CardData] = [
	preload("res://data/card_data/volupta_newblood.tres"),
	preload("res://data/card_data/primori_newblood.tres"),
	preload("res://data/card_data/vorace_newblood.tres"),
]

const ZOOM_SCENE: PackedScene = preload("res://game_pieces/minion_zoom.tscn")

func _get_zoom_scene() -> PackedScene:
	return ZOOM_SCENE

func _ready() -> void:
	super()
	card_type = CardData.CardType.MINION
	size = CARD_SIZE
	custom_minimum_size = CARD_SIZE
	image_panel.custom_minimum_size.y = 88
	_random_stats()

func _setup_styleboxes() -> void:
	if !is_node_ready():
		await get_tree().process_frame
	
	image_panel.add_theme_stylebox_override("panel", MINION_TOP)
	actions_panel.add_theme_stylebox_override("panel", MINION_BOTTOM)
	_sb_normal = MINION_NORMAL
	_sb_selected = MINION_HIGHLIGHT

	_apply_availability_stylebox()

func _random_stats() -> void:
	card_data = DATA_OPTIONS[randi() % DATA_OPTIONS.size()]
