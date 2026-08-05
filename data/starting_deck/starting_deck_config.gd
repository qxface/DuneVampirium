@tool
class_name StartingDeckConfig
extends Resource

# Defines the starting Plan deck and Minion roster every player begins a game with.
# GameState._ready() loads one of these (currently a single hardcoded default — see
# GameState._DEFAULT_STARTING_DECK) and applies it identically to all players.
#
# Plans: each entry's copies all go into plan_draw_pile (shuffled together), matching
# a normal deck-builder's starting deck.
# Minions: each entry's copies go straight into ready_minions (no draw/shuffle step —
# Minions are a standing roster, not deck-built; see the Minion lifecycle decision in
# CLAUDE.md).

@export var plans: Array[StartingCardCount] = []
@export var minions: Array[StartingCardCount] = []
