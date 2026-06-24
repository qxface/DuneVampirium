class_name Plan
extends Card

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
	_sb_normal = preload("uid://djf0c66c23ehw")
	_sb_selected = preload("uid://dbi88yeera2l8")
	card_type = CardData.CardType.PLAN
	_random_stats()

func _random_stats() -> void:
	card_data = DATA_OPTIONS[randi() % DATA_OPTIONS.size()]
