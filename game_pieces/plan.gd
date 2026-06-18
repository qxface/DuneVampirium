class_name Plan
extends Card

func _ready() -> void:
	super()
	card_type = CardData.CardType.PLAN
	size = Vector2(175, 250)
	custom_minimum_size = size
	image_panel.custom_minimum_size.y = 88

func _setup_styleboxes() -> void:
	if !is_node_ready():
		await get_tree().process_frame
	
	image_panel.add_theme_stylebox_override("panel", PLAN_TOP)
	actions_panel.add_theme_stylebox_override("panel", PLAN_BOTTOM)
	_sb_normal = PLAN_NORMAL
	_sb_selected = PLAN_HIGHLIGHT
	
	_set_stylebox(_sb_normal)
