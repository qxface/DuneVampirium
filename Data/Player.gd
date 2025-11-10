# res://Data/Player.gd
class_name Player
extends Resource

@export var player_name: String = ""
@export var player_color: Color = Color.WHITE

# All cards are regular Card instances with appropriate card_type
var draw_pile: Array[Card] = []
var discard_pile: Array[Card] = []
var hand: Array[Card] = []
var minion_pile: Array[Card] = []

func _init(name: String = "", color: Color = Color.WHITE):
	player_name = name
	player_color = color
