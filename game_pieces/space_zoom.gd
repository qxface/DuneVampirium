extends Space

func _ready() -> void:
	super()
	_sb_base = preload("res://assets/styleboxes/spacezoom_selected.tres")
	_sb_selected_glow = preload("res://assets/styleboxes/spacezoom_selected.tres")

# The zoom popup never sets available/selected (SpaceZoom.show_zoom_of() only copies
# space_data) — without this override it would sit at the default available=false and
# render dimmed, which isn't the point of an inspect view. Always full-bright instead.
func _apply_dim() -> void:
	modulate = Color(1, 1, 1, 1)
