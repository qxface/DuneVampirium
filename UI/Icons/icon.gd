# res://UI/Icons/icon.gd
class_name Icon
extends TextureRect

enum Pic {PRIMORI, VOLUPTA, VORACE,
	INTRIGUE, HUNTING, BATTLE,
	VAMPIRE, SUPERNATURAL, HUMAN,
	MONEY, BLOOD, SECRET,
	DRAW_PLAN, DISCARD_PLAN, TRASH_PLAN,
}

@onready var tag_map_left: TextureRect = %TagMapLeft
@onready var tag_map_right: TextureRect = %TagMapRight
@onready var tag_left: TextureRect = $TagLeft
@onready var tag_right: TextureRect = $TagRight
@onready var tag_label_left: Label = %TagLabelLeft
@onready var tag_label_right: Label = %TagLabelRight
	# Base tag size relative to the icon size (adjust these ratios as needed)
var tag_width_ratio: float = 0.25  # Tags will be 25% of icon width
var tag_margin_ratio: float = 0.05  # Margin will be 5% of icon size

@export var color: Color = Color("#f4f3ef")
	#set(value):
		#color = value
		## Defer the actual color application until nodes are ready
		#if is_node_ready():
			#_apply_color(value)
		#else:
			#call_deferred("_apply_color", value)

# Edit file: res://UI/Icons/icon.gd
var icon_texture: String:
	set(value):
		# Check if the string value is a valid file path with an existing image file
		if value and ResourceLoader.exists(value):
			# Load and set the texture
			var loaded_texture = load(value)
			if loaded_texture:
				texture = loaded_texture
		else:
			# If the path is invalid or empty, clear the texture
			texture = null
var tag_l: bool = false:
	set(value):
		tag_l = value
		_update_shader_parameters()
var tag_r: bool = true:
	set(value):
		tag_r = value
		_update_shader_parameters()
var tag: String = "":
	set(value):
		value = value.strip_edges()
		
		if value.length() > 2:
			push_error("Tag value '" + value + "' is too long (max 2 characters)")
			tag = ""
			return
		
		# Validate characters and replace invalid ones with "?"
		var valid_chars = "0123456789+-^v"
		var cleaned_value = ""
		var has_invalid_chars = false
		
		for i in range(value.length()):
			var single_char = value[i]
			if valid_chars.contains(single_char):
				cleaned_value += single_char
			else:
				cleaned_value += "?"
				has_invalid_chars = true
				push_error("Tag value '" + value + "' contains invalid character '" + single_char + "'")
		
		if has_invalid_chars:
			value = cleaned_value
		
		tag = value
		
		# Handle label text based on string length
		if value.length() == 0:
			tag_left.visible = false
			tag_right.visible = false
			tag_label_left.text = ""
			tag_label_right.text = ""
		elif value.length() == 1:
			tag_left.visible = false
			tag_right.visible = true
			tag_label_left.text = ""
			tag_label_right.text = value[0]
		elif value.length() == 2:
			tag_left.visible = true
			tag_right.visible = true
			tag_label_left.text = value[0]
			tag_label_right.text = value[1]

func _ready():
	# Hide the tag maps (they're only used for the shader)
	tag_map_left.visible = false
	tag_map_right.visible = false
	
	## Create and apply the shader material
	#var shader_material = ShaderMaterial.new()
	#shader_material.shader = load("res://UI/Shaders/icon_cutout.gdshader")
		#
	## Set the texture uniforms
	#shader_material.set_shader_parameter("base_texture", texture)
	#shader_material.set_shader_parameter("tag_left_texture", tag_map_left.texture)
	#shader_material.set_shader_parameter("tag_right_texture", tag_map_right.texture)
	#
	## Apply the material
	#material = shader_material
	
	_update_shader_parameters()
	call_deferred('update_color')
	call_deferred('_update_tag_positioning')
func _update_shader_parameters():
	pass
	if material is ShaderMaterial:
		material.set_shader_parameter("tag_l", tag_l)
		material.set_shader_parameter("tag_r", tag_r)

#func _apply_color(new_color: Color):
	#self_modulate = new_color
	#if tag_left:
		#tag_left.self_modulate = new_color
	#if tag_right:
		#tag_right.self_modulate = new_color
	##tag_label_left.label_settings.font_new_color = Color.GREEN
	##tag_label_right.label_settings.font_new_color = Color.RED
	#await get_tree().process_frame
	#if Helper.color_light(new_color):
		#tag_label_left.label_settings.font_color = Color.PINK
		#tag_label_right.label_settings.font_color = Color.PINK
	#else:
		#tag_label_left.label_settings.font_color = Color.ORANGE
		#tag_label_right.label_settings.font_color = Color.ORANGE

func _update_tag_positioning():
	if not texture:
		return

	# Calculate the actual scaled texture size within the TextureRect
	var texture_size = texture.get_size()
	var container_size_x = size.x
	var container_size_y = size.y
	#var container_size = min(size.x, size.y)

	# Calculate the scale factor based on proportional stretch modes
	var scale_factor: float
	if stretch_mode == STRETCH_SCALE or stretch_mode == STRETCH_KEEP_ASPECT or stretch_mode == STRETCH_KEEP_ASPECT_CENTERED:
		# For proportional scaling modes, calculate the actual scale (fit width behaviour)
		if texture_size.x != 0:
			scale_factor = container_size_y / texture_size.y
		else:
			scale_factor = 1.0
	else:
		# For non-proportional modes, use the container size (no extra scaling)
		scale_factor = 1.0

	var scale_power: int = Helper.biggest_power_of_2(scale_factor)
	# Calculate the scaled texture dimensions
	var scaled_texture_width = texture_size.x * scale_factor

	# Calculate tag size based on scaled texture
	var tag_width = scaled_texture_width * tag_width_ratio
	
	# Set tag sizes
	if tag_left:
		#tag_left.custom_minimum_size = Vector2(tag_width, tag_width)
		tag_left.scale = Vector2(scale_factor, scale_factor)
	if tag_right:
		#tag_right.custom_minimum_size = Vector2(tag_width, tag_width)
		tag_right.scale = Vector2(scale_factor, scale_factor)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_update_tag_positioning()
func _on_timer_timeout() -> void:
	var color_array = PALETTE.colors
	var random_index = randi() % color_array.size()
	var random_color = color_array[random_index]
	color = random_color
	var valid_chars = "0123456789+-^v"
	var random_string = ""
	
	# Determine length: 50% chance for 1 character, 50% for 2 characters
	var length = 1 if randi() % 2 == 0 else 2
	
	# Generate random characters
	for i in range(length):
		random_index = randi() % valid_chars.length()
		random_string += valid_chars[random_index]
	
	# Set the tag, which will trigger the validation and texture loading
	tag = random_string

# Edit file: res://UI/Icons/icon.gd
func update_color() -> void:
	# Look up the parent tree until we find a ColorRect
	var parent_color: Color = Helper.find_parent_rect_color(self)
	
	if Helper.color_light(parent_color):
		self_modulate = PALETTE.dark
		tag_left.self_modulate = PALETTE.dark
		tag_right.self_modulate = PALETTE.dark
		tag_label_left.add_theme_color_override("font_color", PALETTE.light)
		tag_label_right.add_theme_color_override("font_color", PALETTE.light)
	else:
		self_modulate = PALETTE.light
		tag_left.self_modulate = PALETTE.light
		tag_right.self_modulate = PALETTE.light
		tag_label_left.add_theme_color_override("font_color", PALETTE.dark)
		tag_label_right.add_theme_color_override("font_color", PALETTE.dark)
