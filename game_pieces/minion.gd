class_name Minion
extends Card

const DATA_DIR: String = "res://data/minions/"
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
	var files: PackedStringArray = DirAccess.get_files_at(DATA_DIR)
	var options: Array[CardData] = []
	for file in files:
		if file.ends_with(".tres"):
			options.append(load(DATA_DIR + file))
	if options.is_empty():
		push_warning("Minion: no CardData resources found in " + DATA_DIR)
		return
	card_data = options[randi() % options.size()]
