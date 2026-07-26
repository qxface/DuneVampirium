class_name ActionDisplay

# Populates the IconContainer (inside IconMargin) of `panel` with action icons.
# Order: [req type icon] [requirement.png]  [cost type icon] [cost.png]  [effect icon] ...
static func populate(panel: Panel, effects: Array, cost_type: int, cost_amount: int, req_type: int, req_amount: int) -> void:
	var hbox := panel.get_node_or_null("IconMargin/IconContainer") as HBoxContainer
	if hbox == null:
		push_warning("ActionDisplay: no IconMargin/IconContainer found in %s" % panel.name)
		return
	populate_into(hbox, effects, cost_type, cost_amount, req_type, req_amount)

static func populate_into(hbox: HBoxContainer, effects: Array, cost_type: int, cost_amount: int, req_type: int, req_amount: int) -> void:
	for child in hbox.get_children():
		child.free()

	if effects.is_empty():
		return

	if req_type != GameEnums.RequirementType.NONE:
		add_typed_icon(hbox, GameEnums.requirement_icon_path(req_type as GameEnums.RequirementType), req_amount, true)
		_add_path(hbox, "res://assets/icons/instructions/requirement.png")

	if cost_type != GameEnums.CostType.NONE:
		add_typed_icon(hbox, GameEnums.cost_icon_path(cost_type as GameEnums.CostType), cost_amount, false)
		_add_path(hbox, "res://assets/icons/instructions/cost.png")

	for effect in effects:
		if effect != null:
			var tex: Texture2D = effect.get_icon()
			if tex != null:
				add_effect_icon(hbox, tex, effect.get_tags())

static func amount_tag(amount: int) -> String:
	return "" if amount <= 0 else str(clampi(amount, 0, 99))

# Requirements read as "at least N" (a held threshold, not spent), so they're tagged
# "N+" — left pip the digit, right pip a literal "+" — to visually distinguish them
# from costs at a glance. Requirements are assumed to never exceed 9.
static func requirement_tag(amount: int) -> String:
	return "" if amount <= 0 or amount > 9 else "%d+" % amount

# Adds an Icon scene carrying an amount tag for a cost/requirement type icon at `path`.
# Shared by ActionDisplay's own cost/requirement icons and Space's per-clause icons.
# is_requirement selects the "N+" requirement tag format instead of the plain cost tag.
static func add_typed_icon(container: HBoxContainer, path: String, amount: int, is_requirement: bool = false) -> void:
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var tag: String = requirement_tag(amount) if is_requirement else amount_tag(amount)
	add_effect_icon(container, load(path), tag)

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

static var _icon_scene: PackedScene = preload("res://game_pieces/icon.tscn")

static func add_effect_icon(container: HBoxContainer, texture: Texture2D, tags: String) -> void:
	var icon = _icon_scene.instantiate()
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(icon)
	icon.icon = texture
	icon.tags = tags
