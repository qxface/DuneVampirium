# res://BoardParts/card_base.gd
# TODO: CardZoom should connect to plan/minion signals based on `display_plans` (see res://BoardParts/ZoomArea/card_zoom.gd)
# res://BoardParts/plan_base.gd
# res://BoardParts/PlayerHand/plan_hand.gd
class_name CardBase
extends Panel

@export var display_plans: bool = true

#enum CardParts {
	#PRIMORI_BG, VOLUPTA, VORACE,
	#PRIMORI_ICON, HEART, SKULL,
	#INTRIGUE, HUNTING, BATTLE,
	#TRIANGLE, RHOMBUS, PENTAGON,
	#ORIGIN,
	#ACQUIRE, ACTION, REVEAL, DISCARD, TRASH
#}

const OUTLINE_THICKNESS = 2.0
const MINION_CHOSEN = preload("uid://doyxvbprnuly6")
const MINION_HIGHLIGHT = preload("uid://bbiot6luxhtjd")
const MINION_NORMAL = preload("uid://cxtb8u2qyj1pb")
const PLAN_CHOSEN = preload("uid://c2x6pcg3kefeq")
const PLAN_HIGHLIGHT = preload("uid://d08x7kotsajk6")
const PLAN_NORMAL = preload("uid://ce52ar8aullls")

const HUMAN_ICON = preload("uid://ccwkfkibyebxn")
const SUPERNATURAL_ICON = preload("uid://6lqnj8qgqwsn")
const VAMPIRE_ICON = preload("uid://cpij7h4qc4i0i")

@export var border: StyleBoxFlat = preload("uid://ce52ar8aullls")

var origin_color: Dictionary ={
	Card.OriginType.VAMPIRE: PALETTE.gold,
	Card.OriginType.SUPERNATURAL: PALETTE.silver,
	Card.OriginType.HUMAN: PALETTE.bronze,
	Card.OriginType.NONE: PALETTE.dark,
}

#@onready var background: TextureRect = get_node_or_null("Background") as TextureRect
@onready var icons: HBoxContainer = %Icons
@onready var v_split_container: VSplitContainer = %VSplitContainer
@onready var card_name: RichTextLabel = %CardName


@onready var primori_bg: ColorRect = %Primori_BG
@onready var primori_icon: TextureRect = %Primori_Icon
@onready var volupta_bg: ColorRect = %Volupta_BG
@onready var volupta_icon: TextureRect = %Volupta_Icon
@onready var vorace_bg: ColorRect = %Vorace_BG
@onready var vorace_icon: TextureRect = %Vorace_Icon

@onready var intrigue_bg: ColorRect = %Intrigue_BG
@onready var intrigue_icon: TextureRect = %Intrigue_Icon
@onready var hunting_bg: ColorRect = %Hunting_BG
@onready var hunting_icon: TextureRect = %Hunting_Icon
@onready var battle_bg: ColorRect = %Battle_BG
@onready var battle_icon: TextureRect = %Battle_Icon

@onready var origin_bg: ColorRect = %Origin_BG
@onready var origin_icon: TextureRect = %Origin_Icon

@onready var acquire_bg: ColorRect = %Acquire_BG
@onready var action_bg: ColorRect = %Action_BG
@onready var reveal_bg: ColorRect = %Reveal_BG
@onready var discard_bg: ColorRect = %Discard_BG
@onready var trash_bg: ColorRect = %Trash_BG

@onready var acquire_icons: ActivationIcons = %AcquireIcons
@onready var action_icons: ActivationIcons = %ActionIcons
@onready var reveal_icons: ActivationIcons = %RevealIcons
@onready var discard_icons: ActivationIcons = %DiscardIcons
@onready var trash_icons: ActivationIcons = %TrashIcons

var card_parts: Dictionary = {}

var player: Player
var card_data: Card

func _ready():
	pass

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_mouse_left_click()
			if is_inside_tree():
				get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_on_mouse_right_click()
			if is_inside_tree():
				get_viewport().set_input_as_handled()

func _on_mouse_left_click() -> void:
	pass

func _on_mouse_right_click() -> void:
	pass

func _on_mouse_entered() -> void:
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	pass # Replace with function body.

func _update_display():
	if card_data == null:
		_hide_all_indicators()
		return
	assert(is_inside_tree(), "Setting Card data before adding Plan to Scene Tree")
	if !ready:
		await get_tree().process_frame 
	
	card_name.text = card_data.card_name
	match card_data.card_type:
		Card.CardType.PLAN:
			card_name.add_theme_stylebox_override("background", PLAN_NORMAL)
			card_name.add_theme_color_override("default_color", PALETTE.grey)
		Card.CardType.MINION:
			card_name.add_theme_stylebox_override("background", MINION_NORMAL)
			card_name.add_theme_color_override("default_color", PALETTE.light)
	

	# Update clan indicators (only show if true)
	primori_bg.visible = card_data.is_primori
	volupta_bg.visible = card_data.is_volupta
	vorace_bg.visible = card_data.is_vorace
	
	intrigue_bg.visible = card_data.is_intrigue
	hunting_bg.visible = card_data.is_hunting
	battle_bg.visible = card_data.is_battle
	
	acquire_bg.visible = card_data.has_acquire
	action_bg.visible = card_data.has_action
	reveal_bg.visible = card_data.has_reveal
	discard_bg.visible = card_data.has_discard
	trash_bg.visible = card_data.has_trash
	
	var is_none: bool = (card_data.origin == Card.OriginType.NONE)
	if is_none:
		origin_bg.visible = false
	else:
		origin_bg.visible = true
		match card_data.origin:
			Card.OriginType.VAMPIRE:
				origin_icon.texture = VAMPIRE_ICON
			Card.OriginType.SUPERNATURAL:
				origin_icon.texture = SUPERNATURAL_ICON
			Card.OriginType.HUMAN:
				origin_icon.texture = HUMAN_ICON
			_:
				origin_bg.visible = false
		origin_icon.self_modulate = origin_color[card_data.origin]

func set_card_data(card: Card):
	card_data = card
	_update_display()

func _hide_all_indicators():
	# Hide all clan indicators
	primori_bg.visible = false
	volupta_bg.visible = false
	vorace_bg.visible = false
	
	intrigue_bg.visible = false
	hunting_bg.visible = false
	battle_bg.visible = false
	
	origin_bg.visible = false
	
	acquire_bg.visible = false
	action_bg.visible = false
	reveal_bg.visible = false
	discard_bg.visible = false
	trash_bg.visible = false
