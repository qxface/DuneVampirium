class_name Icon
extends TextureRect

enum Pic {PRIMORI, VOLUPTA, VORACE,
	INTRIGUE, HUNTING, BATTLE,
	VAMPIRE, SUPERNATURAL, HUMAN,
	MONEY, BLOOD, SECRET,
	DRAW_PLAN, DISCARD_PLAN, TRASH_PLAN,
}

const LIGHT: Color = Color("#f4f3ef")
const DARK: Color = Color("#16171b")
const PALETTE = preload("res://UI/vampire_palette.tres")

@onready var tag_map_left: TextureRect = %TagMapLeft
@onready var tag_map_right: TextureRect = %TagMapRight
@onready var tag_left: TextureRect = %TagLeft
@onready var tag_right: TextureRect = %TagRight
@onready var tag_label_left: Label = %TagLabelLeft
@onready var tag_label_right: Label = %TagLabelRight

@export var color: Color = Color("#f4f3ef"):
	set(value):
		color = value
		# Defer the actual color application until nodes are ready
		if is_node_ready():
			_apply_color()
		else:
			call_deferred("_apply_color")

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
				cleaned_value += char
			else:
				cleaned_value += "?"
				has_invalid_chars = true
				push_error("Tag value '" + value + "' contains invalid character '" + single_char + "'")
		
		if has_invalid_chars:
			value = cleaned_value
		
		tag = value
		
		# Handle label text based on string length
		if value.length() == 0:
			tag_label_left.text = ""
			tag_label_right.text = ""
		elif value.length() == 1:
			tag_label_left.text = ""
			tag_label_right.text = value[0]
		elif value.length() == 2:
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

func _update_shader_parameters():
	pass
	if material is ShaderMaterial:
		material.set_shader_parameter("tag_l", tag_l)
		material.set_shader_parameter("tag_r", tag_r)

func _apply_color():
	self_modulate = color
	if tag_left:
		tag_left.self_modulate = color
	if tag_right:
		tag_right.self_modulate = color
	if tag_label_left and tag_label_right:
		if Helper.color_light(color):
			tag_label_left.label_settings.font_color = DARK
			tag_label_right.label_settings.font_color = DARK
		else:
			tag_label_left.label_settings.font_color = LIGHT
			tag_label_right.label_settings.font_color = LIGHT

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
