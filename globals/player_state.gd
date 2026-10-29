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
var fight: int = 0      # Temporary — banked at Reveal, contributed to Combat, then reset to 0 at round end
var influence: int = 0  # Temporary — banked at Reveal, spent on Plans after revealing, then reset to 0 at round end
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

# --- Undo support ---
#
# Captures/restores every field that changes during normal play. Arrays/Dictionaries
# are duplicated (not referenced) on both ends so a snapshot taken before an action
# stays untouched by whatever that action — or a later restore — does afterward. See
# GameState.snapshot()/restore() for the per-player callers of these.
func snapshot() -> Dictionary:
	return {
		"vp": vp,
		"money": money,
		"blood": blood,
		"secrets": secrets,
		"fight": fight,
		"influence": influence,
		"rapport": rapport.duplicate(),
		"ready_minions": ready_minions.duplicate(),
		"placed_minions": placed_minions.duplicate(),
		"plan_draw_pile": plan_draw_pile.duplicate(),
		"plan_hand": plan_hand.duplicate(),
		"plan_in_play": plan_in_play.duplicate(),
		"plan_discard": plan_discard.duplicate(),
		"actions_remaining": actions_remaining,
		"round_phase": round_phase,
	}

func restore_from(snap: Dictionary) -> void:
	vp = snap["vp"]
	money = snap["money"]
	blood = snap["blood"]
	secrets = snap["secrets"]
	fight = snap["fight"]
	influence = snap["influence"]
	rapport = (snap["rapport"] as Dictionary).duplicate()
	# .assign() (not a reassign + cast) so each typed Array field keeps its own identity
	# and CardData element type while copying the snapshot's contents in.
	ready_minions.assign(snap["ready_minions"])
	placed_minions.assign(snap["placed_minions"])
	plan_draw_pile.assign(snap["plan_draw_pile"])
	plan_hand.assign(snap["plan_hand"])
	plan_in_play.assign(snap["plan_in_play"])
	plan_discard.assign(snap["plan_discard"])
	actions_remaining = snap["actions_remaining"]
	round_phase = snap["round_phase"]
