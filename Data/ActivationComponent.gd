# New file: res://Data/ActivationComponent.gd
class_name ActivationComponent
extends Resource

enum ComponentType { REQUIREMENT, COST, REWARD }

@export var component_type: ComponentType
@export var icon_texture_path: String = ""
@export var tag: String = ""
@export var description: String = ""

# Base functionality - to be overridden by subclasses
func is_met(player: Player) -> bool:
	return false

func can_pay(player: Player) -> bool:
	return false

func pay(player: Player) -> bool:
	return false

func execute(player: Player) -> void:
	pass

# Icon helper methods
func get_icon_texture() -> Texture2D:
	if icon_texture_path and ResourceLoader.exists(icon_texture_path):
		return load(icon_texture_path)
	return null

func get_tag_left() -> String:
	if tag.length() >= 2:
		return tag[0]
	return ""

func get_tag_right() -> String:
	if tag.length() == 1:
		return tag[0]
	elif tag.length() >= 2:
		return tag[1]
	return ""
