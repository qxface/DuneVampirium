extends TextureRect

var _tags: String = ""

@onready var tag_left: TextureRect = %TagLeft
@onready var tag_right: TextureRect = %TagRight

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Each instance needs its own ShaderMaterial so cut_left/cut_right uniforms
	# don't bleed across all icons (PackedScene shares sub-resources by default).
	if material != null:
		material = material.duplicate()
	_reposition_tags()
	# Reapply any tags value set during scene loading (before @onready vars were valid).
	tags = _tags

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_reposition_tags()

func _reposition_tags() -> void:
	if not is_node_ready():
		return
	var s := size
	#for tag: TextureRect in [tag_left, tag_left_back, tag_right, tag_right_back]:
	for tag: TextureRect in [tag_left, tag_right]:
		tag.position = Vector2.ZERO
		tag.size = s
		tag.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tag.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

@export var icon: Texture2D:
	set(value):
		texture = value

@export var color: Color:
	set(value):
		self_modulate = value
		tag_left.self_modulate = value
		tag_right.self_modulate = value

@export var tags: String:
	set(value):
		_tags = _clean_tag_values(value)
		if not is_node_ready():
			return
		if _tags.length() == 0:
			tag_left.visible = false
			tag_right.visible = false
		elif _tags.length() == 1:
			tag_left.visible = false
			tag_right.texture = load("res://assets/icons/tags/tag_right_%s.png" % _char_to_tag(_tags[0]))
			tag_right.visible = true
		else:
			tag_left.texture = load("res://assets/icons/tags/tag_left_%s.png" % _char_to_tag(_tags[0]))
			tag_left.visible = true
			tag_right.texture = load("res://assets/icons/tags/tag_right_%s.png" % _char_to_tag(_tags[1]))
			tag_right.visible = true
		_update_cut_uniforms()

func _update_cut_uniforms() -> void:
	if material == null:
		return
	(material as ShaderMaterial).set_shader_parameter("cut_left", tag_left.visible)
	(material as ShaderMaterial).set_shader_parameter("cut_right", tag_right.visible)

func _char_to_tag(ch: String) -> String:
	if ch == "-": return "minus"
	if ch == "+": return "plus"
	return ch

func bg_opposite() -> Color:
	var node: Node = get_parent()
	while node != null:
		if node is Panel:
			var sb := (node as Panel).get_theme_stylebox("panel")
			if sb is StyleBoxFlat:
				var bg: Color = (sb as StyleBoxFlat).bg_color
				# luminance: distance to black vs white
				var lum := bg.r * 0.299 + bg.g * 0.587 + bg.b * 0.114
				return Color.BLACK if lum > 0.5 else Color.WHITE
			return Color.BLACK
		if node == get_tree().root:
			break
		node = node.get_parent()
	return Color.BLACK

func _clean_tag_values(value: String) -> String:
	var trimmed := value.strip_edges()
	if trimmed.length() == 0 or trimmed.length() > 2:
		return ""
	for ch in trimmed:
		if ch not in ["0","1","2","3","4","5","6","7","8","9","+","-"]:
			return ""
	return trimmed
