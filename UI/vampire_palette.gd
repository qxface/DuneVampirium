# res://UI/vampire_palette.gd
extends Node

enum Hue {RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, METAL, NEUTRAL}
enum Tint {LIGHT, NORMAL, DARK}

# Load the palette resource
var palette_resource: Resource = preload("res://UI/vampire_palette.tres")

func color(hue: Hue, tint: Tint) -> Color:
	var hue_offset: int = hue * 3
	var tint_offset: int = tint
	var palette_index: int = hue_offset + tint_offset
	return palette_resource.colors[palette_index] if palette_resource.colors.size() > palette_index else grey

# Red colors
var red_dark: Color:
	get: return palette_resource.colors[0] if palette_resource.colors.size() > 0 else Color.BLACK

var red: Color:
	get: return palette_resource.colors[1] if palette_resource.colors.size() > 1 else Color.BLACK

var red_light: Color:
	get: return palette_resource.colors[2] if palette_resource.colors.size() > 2 else Color.BLACK

# Orange colors
var orange_dark: Color:
	get: return palette_resource.colors[3] if palette_resource.colors.size() > 3 else Color.BLACK

var orange: Color:
	get: return palette_resource.colors[4] if palette_resource.colors.size() > 4 else Color.BLACK

var orange_light: Color:
	get: return palette_resource.colors[5] if palette_resource.colors.size() > 5 else Color.BLACK

# Yellow colors
var yellow_dark: Color:
	get: return palette_resource.colors[6] if palette_resource.colors.size() > 6 else Color.BLACK

var yellow: Color:
	get: return palette_resource.colors[7] if palette_resource.colors.size() > 7 else Color.BLACK

var yellow_light: Color:
	get: return palette_resource.colors[8] if palette_resource.colors.size() > 8 else Color.BLACK

# Green colors
var green_dark: Color:
	get: return palette_resource.colors[9] if palette_resource.colors.size() > 9 else Color.BLACK

var green: Color:
	get: return palette_resource.colors[10] if palette_resource.colors.size() > 10 else Color.BLACK

var green_light: Color:
	get: return palette_resource.colors[11] if palette_resource.colors.size() > 11 else Color.BLACK

# Blue colors
var blue_dark: Color:
	get: return palette_resource.colors[12] if palette_resource.colors.size() > 12 else Color.BLACK

var blue: Color:
	get: return palette_resource.colors[13] if palette_resource.colors.size() > 13 else Color.BLACK

var blue_light: Color:
	get: return palette_resource.colors[14] if palette_resource.colors.size() > 14 else Color.BLACK

# Purple colors
var purple_dark: Color:
	get: return palette_resource.colors[15] if palette_resource.colors.size() > 15 else Color.BLACK

var purple: Color:
	get: return palette_resource.colors[16] if palette_resource.colors.size() > 16 else Color.BLACK

var purple_light: Color:
	get: return palette_resource.colors[17] if palette_resource.colors.size() > 17 else Color.BLACK

# Metallic colors
var gold: Color:
	get: return palette_resource.colors[18] if palette_resource.colors.size() > 18 else Color.BLACK

var silver: Color:
	get: return palette_resource.colors[19] if palette_resource.colors.size() > 19 else Color.BLACK

var bronze: Color:
	get: return palette_resource.colors[20] if palette_resource.colors.size() > 20 else Color.BLACK

# Neutral colors
var dark: Color:
	get: return palette_resource.colors[21] if palette_resource.colors.size() > 21 else Color.BLACK

var grey: Color:
	get: return palette_resource.colors[22] if palette_resource.colors.size() > 22 else Color.BLACK

var light: Color:
	get: return palette_resource.colors[23] if palette_resource.colors.size() > 23 else Color.BLACK
