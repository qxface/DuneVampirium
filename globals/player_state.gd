class_name PlayerState
extends RefCounted

enum RoundPhase {
	ACTIVE,    # Has actions remaining, hasn't revealed yet
	REVEALING, # Triggered Reveal; plans fired; spending leftover actions on Minion Reveals
	DONE,      # Ended reveal turn; nothing more until next round
}

var player_name: String = ""
var is_ai: bool = false
var player_color: Color = Color.WHITE

var vp: int = 0
var money: int = 0
var blood: int = 0
var secrets: int = 0
var fight: int = 0  # Plumbing only for now — no consumer yet, use TBD (see GainResource.GainType.FIGHT)
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
# TEMP: bumped from the 2-action baseline to 3 for testing Place/Recall/Place sequences.
var actions_per_round: int = 3
var actions_remaining: int = 3
var round_phase: RoundPhase = RoundPhase.ACTIVE
