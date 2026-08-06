class_name Minion
extends Card

const DATA_DIR: String = "res://data/minions/"
func _get_zoom_scene() -> PackedScene:
	return load("res://game_pieces/minion_zoom.tscn")

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
		# Exported builds list resources as "name.tres.remap", not "name.tres" —
		# strip that suffix before checking the extension / loading.
		var real_file: String = file.trim_suffix(".remap")
		if real_file.get_extension() in ["tres", "res"]:
			options.append(load(DATA_DIR + real_file))
	if options.is_empty():
		push_warning("Minion: no CardData resources found in " + DATA_DIR)
		return
	card_data = options[randi() % options.size()]
