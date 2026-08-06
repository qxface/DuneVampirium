class_name Plan
extends Card

const DATA_DIR: String = "res://data/plans/"
func _get_zoom_scene() -> PackedScene:
	return load("res://game_pieces/plan_zoom.tscn")

func _ready() -> void:
	super()
	name_panel.visible = false
	_sb_normal = preload("uid://djf0c66c23ehw")
	_sb_selected = preload("uid://dbi88yeera2l8")
	card_type = CardData.CardType.PLAN
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
		push_warning("Plan: no CardData resources found in " + DATA_DIR)
		return
	card_data = options[randi() % options.size()]
