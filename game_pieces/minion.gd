class_name Minion
extends Card

const CARD_SIZE: Vector2 = Vector2(175, 250)

func _ready() -> void:
	super()
	card_type = CardData.CardType.MINION
	size = CARD_SIZE
	custom_minimum_size = CARD_SIZE
	image_panel.custom_minimum_size.y = 88

func _setup_styleboxes() -> void:
	if !is_node_ready():
		await get_tree().process_frame
	
	image_panel.add_theme_stylebox_override("panel", MINION_TOP)
	actions_panel.add_theme_stylebox_override("panel", MINION_BOTTOM)
	_sb_normal = MINION_NORMAL
	_sb_selected = MINION_HIGHLIGHT

	_apply_availability_stylebox()
