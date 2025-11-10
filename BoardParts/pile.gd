# res://BoardParts/pile.gd
class_name Pile
extends TextureButton

signal right_pressed()

@export var pile_name: String = "Pile"
@export var pile_texture: Texture2D = preload("res://assets/piles/draw_pile.png")
@export var pile_color: Color = PALETTE.light

@onready var card_count_label: Label = $CardCountLabel

func _ready() -> void:
	texture_normal = pile_texture
	self_modulate = pile_color

func update_card_count(count: int) -> void:
	if card_count_label:
		card_count_label.text = str(count)

func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_pressed.emit()
