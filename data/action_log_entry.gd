class_name ActionLogEntry
extends RefCounted

# One committed top-level player Action (Place/Recall/Reveal/MinionReveal) — the same
# unit Undo operates on (see GameState.begin_undo_span()/commit_action_log()) and the
# eventual unit an async-multiplayer sync would ship. `snapshot` is the full GameState
# captured immediately before this action executed (GameState.snapshot()), used to
# restore on undo. `description` is a human-readable summary frozen at commit time.
# `params` holds the CardData/SpaceData references needed to redo this action's effects
# in game terms — reusing the existing execute_*() methods rather than a separate
# replay format, per CLAUDE.md's multiplayer architecture note.

var player_index: int = -1
var round_number: int = 0
var description: String = ""
var action_type: String = ""   # "place" / "recall" / "reveal" / "minion_reveal"
var params: Dictionary = {}
var binding: bool = false      # true if any effect this action triggered is_binding()
var snapshot: Dictionary = {}
