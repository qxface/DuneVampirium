@tool
class_name FactionMilestone
extends Resource

# One milestone on a faction track.
# Any player who reaches or passes through `position` when advancing fires all
# effects listed here. These are unconditional, fixed rewards (e.g. +1 VP for
# everyone who hits position 2). The contested leader VP is NOT encoded here —
# it is handled separately by FactionTrackData.leader_vp_position and GameState.

@export var position: int = 0
@export var effects: Array[Effect] = []
