extends Space

func _ready() -> void:
	super()
	_sb_unavailable = preload("res://assets/styleboxes/spacezoom_selected.tres")
	_sb_available = preload("res://assets/styleboxes/spacezoom_selected.tres")
	_sb_selected = preload("res://assets/styleboxes/spacezoom_selected.tres")
