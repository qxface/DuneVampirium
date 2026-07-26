@tool
class_name FactionTrackData
extends Resource

# Data definition for one Faction's advancement track.
#
# faction_name must exactly match the key used in PlayerState.rapport
# (e.g. "primori", "volupta", "vorace", "tenebris").
#
# When a player reaches leader_vp_position, GameState checks whether they are
# now strictly higher than the current leader and swaps the contested VP
# immediately (new leader gains 1, old leader loses 1). Ties go to the first
# player who reached that position — they keep the VP.
# Set leader_vp_position = 0 to disable the contested-leader mechanic entirely
# for this track.
#
# milestones should be ordered by ascending position, though GameState will
# fire them correctly regardless of order.

@export var faction_name: String = ""
@export var max_position: int = 4

## Minimum position a player must hold to compete for the contested leader VP.
## 0 = no leader VP on this track.
@export var leader_vp_position: int = 4

## Fixed-reward milestones. Each milestone fires its effects for every player
## who crosses or lands on that position.
@export var milestones: Array[FactionMilestone] = []
