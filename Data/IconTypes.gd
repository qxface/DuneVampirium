# Edit file: res://Data/IconTypes.gd
class_name IconTypes
extends RefCounted

# Consolidated enum for all icon types
enum Type {
	BLOOD,
	MONEY,
	SECRETS,
	PLAN,
	PLAN_TRASH,
	INFLUENCE
}

# Dictionary mapping each type to its Hue
static var hue_mapping: Dictionary = {
	Type.BLOOD: PALETTE.Hue.RED,
	Type.MONEY: PALETTE.Hue.GREEN,
	Type.SECRETS: PALETTE.Hue.PURPLE,
	Type.PLAN: PALETTE.Hue.BLUE,
	Type.PLAN_TRASH: PALETTE.Hue.NEUTRAL,
	Type.INFLUENCE: PALETTE.Hue.GREEN
}

# Dictionary mapping each type to its icon texture path
static var texture_mapping: Dictionary = {
	Type.BLOOD: "res://assets/icons/resources/blood.png",
	Type.MONEY: "res://assets/icons/resources/money.png",
	Type.SECRETS: "res://assets/icons/resources/secret.png",
	Type.PLAN: "res://assets/piles/draw_pile.png",
	Type.PLAN_TRASH: "res://assets/piles/discard_pile.png", # Need actual trash icon
	Type.INFLUENCE: "res://assets/icons/resources/influence.png" # Need actual influence icon
}

# Get the Hue for a specific type
static func get_hue(type: Type) -> int:
	return hue_mapping.get(type, PALETTE.Hue.NEUTRAL)

# Get the texture path for a specific type
static func get_texture_path(type: Type) -> String:
	return texture_mapping.get(type, "")

# Get the appropriate tint (LIGHT or DARK) based on background color
static func get_tint_for_background(background_color: Color) -> int:
	if Helper.color_light(background_color):
		return PALETTE.Tint.NORMAL
	else:
		return PALETTE.Tint.LIGHT

# Get the final color for a type on a specific background using the existing PALETTE.color() method
static func get_color(type: Type, background_color: Color) -> Color:
	var hue = get_hue(type)
	var tint = get_tint_for_background(background_color)
	return PALETTE.color(hue, tint)
