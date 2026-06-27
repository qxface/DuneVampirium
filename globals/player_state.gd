class_name PlayerState
extends RefCounted

var player_name: String = ""
var is_ai: bool = false

var vp: int = 0
var money: int = 0
var blood: int = 0
var secrets: int = 0
var rapport: Dictionary = {}  # String (faction name) -> int

# Minion zones
var ready_minions: Array[CardData] = []   # in the Ready Minion Zone (hand)
var placed_minions: Array[CardData] = []  # currently on board spaces

# Plan zones
var plan_draw_pile: Array[CardData] = []
var plan_hand: Array[CardData] = []
var plan_in_play: Array[CardData] = []
var plan_discard: Array[CardData] = []

# Turn economy
var actions_per_round: int = 2
var actions_remaining: int = 2
var has_revealed: bool = false
