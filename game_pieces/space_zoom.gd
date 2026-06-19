extends Space

# A Space that blows itself up to fill most of the screen for the long-press
# "get a closer look" popup. Sets _size_scale_factor before any data is loaded
# so pip rows and styleboxes are drawn at the larger proportional size.

const SPACE_ASPECT: float = 250.0 / 125.0

func _ready() -> void:
	_resize_to_fill_screen()
	super()

func _resize_to_fill_screen() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var target_width: float = viewport_size.x * 0.85
	var target_height: float = target_width / SPACE_ASPECT
	if target_height > viewport_size.y * 0.85:
		target_height = viewport_size.y * 0.85
		target_width = target_height * SPACE_ASPECT
	custom_minimum_size = Vector2(target_width, target_height)
	size = custom_minimum_size
	_size_scale_factor = target_height / 125.0
