class_name Plan
extends Card

const CARD_SIZE: Vector2 = Vector2(175, 250)

const DATA_OPTIONS: Array[CardData] = [
	preload("res://data/card_data/campaign.tres"),
	preload("res://data/card_data/feed.tres"),
	preload("res://data/card_data/bodice_ripping_catfight.tres"),
]

const ZOOM_SCENE: PackedScene = preload("res://game_pieces/plan_zoom.tscn")

func _get_zoom_scene() -> PackedScene:
	return ZOOM_SCENE

func _ready() -> void:
	super()
	card_type = CardData.CardType.PLAN
	size = CARD_SIZE
	custom_minimum_size = CARD_SIZE
	image_panel.custom_minimum_size.y = 88
	_random_stats()

func _random_stats() -> void:
	card_data = DATA_OPTIONS[randi() % DATA_OPTIONS.size()]

func _setup_styleboxes() -> void:
	if !is_node_ready():
		await get_tree().process_frame
	
	image_panel.add_theme_stylebox_override("panel", PLAN_TOP)
	actions_panel.add_theme_stylebox_override("panel", PLAN_BOTTOM)
	_sb_normal = PLAN_NORMAL
	_sb_selected = PLAN_HIGHLIGHT

	_apply_availability_stylebox()
