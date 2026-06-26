class_name ActionDisplay

# Populates the IconContainer (inside IconMargin) of `panel` with action icons.
# Order: [req type icon] [requirement.png]  [cost type icon] [cost.png]  [effect icon] ...
static func populate(panel: Panel, effects: Array, cost_type: int, req_type: int) -> void:
	var hbox := panel.get_node_or_null("IconMargin/IconContainer") as HBoxContainer
	if hbox == null:
		push_warning("ActionDisplay: no IconMargin/IconContainer found in %s" % panel.name)
		return
	populate_into(hbox, effects, cost_type, req_type)

static func populate_into(hbox: HBoxContainer, effects: Array, cost_type: int, req_type: int) -> void:
	for child in hbox.get_children():
		child.free()

	if effects.is_empty():
		return

	if req_type != GameEnums.RequirementType.NONE:
		_add_path(hbox, GameEnums.requirement_icon_path(req_type as GameEnums.RequirementType))
		_add_path(hbox, "res://assets/icons/instructions/requirement.png")

	if cost_type != GameEnums.CostType.NONE:
		_add_path(hbox, GameEnums.cost_icon_path(cost_type as GameEnums.CostType))
		_add_path(hbox, "res://assets/icons/instructions/cost.png")

	for effect in effects:
		if effect != null:
			var tex: Texture2D = effect.get_icon()
			if tex != null:
				_add_texture(hbox, tex)

static func _add_path(container: HBoxContainer, path: String) -> void:
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	_add_texture(container, load(path))

static func _add_texture(container: HBoxContainer, texture: Texture2D) -> void:
	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(rect)
