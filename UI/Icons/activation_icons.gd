# res://UI/Icons/activation_icons.gd
class_name ActivationIcons
extends HBoxContainer

@onready var requirement: Icon = %Requirement
@onready var colon: TextureRect = %Colon
@onready var cost: Icon = %Cost
@onready var arrow: TextureRect = %Arrow
@onready var reward: Icon = %Reward

var expandable_textures:= []

func _ready():
	halve_textures()
	call_deferred("update_color")

func halve_textures() -> void:
	requirement.scale = Vector2(.5, .5)
	cost.scale = Vector2(.5, .5)
	#reward.scale = Vector2(.5, .5)

func update_icons(activation: Activation) -> void:
	visible = false
	if activation:
		visible = true

	# Set reward icon if available
	# if an activation has no reward, it can never have a cost or a requirement
	if activation.reward:
		var reward_icon_path: String = activation.reward.icon_texture_path
		reward.icon_texture = reward_icon_path
		reward.tag = activation.reward.tag
	else:
		requirement.hide()
		colon.hide()
		cost.hide()
		arrow.hide()
		reward.hide()

	# Handle cost visibility
	if activation.cost:
		cost.icon_texture = activation.cost.icon_texture_path
		cost.show()
		arrow.show()
	else:
		cost.hide()
		arrow.hide()

	# Handle requirement visibility
	if activation.requirement:
		requirement.icon_texture = activation.requirement.icon_texture_path
		requirement.show()
		arrow.show()
	else:
		requirement.hide()
		colon.hide()

func update_color() -> void:
	# Look up the parent tree until we find a ColorRect
	var parent_color: Color = Helper.find_parent_rect_color(self)
	
	if Helper.color_light(parent_color):
		colon.self_modulate = PALETTE.dark
		arrow.self_modulate = PALETTE.dark
	else:
		colon.self_modulate = PALETTE.light
		arrow.self_modulate = PALETTE.light
## Tag methods (assuming tag is displayed in the reward icon or elsewhere)
#func set_tag(tag_text: String) -> void:
	## You'll need to implement this based on where you want to display the tag
	## For example, if you have a label for the tag:
	#pass
#
#func hide_tag() -> void:
	## Hide the tag display
	#pass
#
## Cost methods
#func set_cost(cost_amount: int) -> void:
	#cost.visible = true
	## Assuming your Icon class has a method to set the cost display
	#if cost.has_method("set_cost"):
		#cost.set_cost(cost_amount)
#
#func hide_cost() -> void:
	#cost.visible = false
#
## Requirement methods
#func set_requirement(requirement_text: String) -> void:
	#requirement.visible = true
	#colon.visible = true
	## Assuming your Icon class has a method to set the requirement
	#if requirement.has_method("set_requirement"):
		#requirement.set_requirement(requirement_text)
#
#func hide_requirement() -> void:
	#requirement.visible = false
#
## Helper methods for arrow and colon
#func hide_arrow() -> void:
	#arrow.visible = false
#
#func hide_colon() -> void:
	#colon.visible = false
