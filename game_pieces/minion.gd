class_name Minion
extends Card

const DATA_OPTIONS: Array[CardData] = [
	preload("res://data/card_data/volupta_newblood.tres"),
	preload("res://data/card_data/primori_newblood.tres"),
	preload("res://data/card_data/vorace_newblood.tres"),
]

const ZOOM_SCENE: PackedScene = preload("res://game_pieces/minion_zoom.tscn")

func _get_zoom_scene() -> PackedScene:
	return ZOOM_SCENE

func _ready() -> void:
	_sb_normal = preload("uid://dkl6uaeopqebv")
	_sb_selected = preload("uid://ijg8sosaoco8")
	card_type = CardData.CardType.MINION
	super()
	_random_stats()

func _random_stats() -> void:
	card_data = DATA_OPTIONS[randi() % DATA_OPTIONS.size()]
