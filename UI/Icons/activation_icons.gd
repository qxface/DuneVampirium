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

func halve_textures() -> void:
	requirement.scale = Vector2(.5, .5)
	cost.scale = Vector2(.5, .5)
	#reward.scale = Vector2(.5, .5)
