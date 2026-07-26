class_name Track
extends Panel

# faction_name must match a key in GameState.faction_tracks (and PlayerState.rapport) —
# set per-instance in the Inspector (e.g. "primori", "volupta", "vorace").
@export var faction_name: String = ""

@onready var _steps: Array[TrackStep] = [
	$MarginContainer/VBoxContainer/TrackStep,
	$MarginContainer/VBoxContainer/TrackStep2,
	$MarginContainer/VBoxContainer/TrackStep3,
	$MarginContainer/VBoxContainer/TrackStep4,
	$MarginContainer/VBoxContainer/TrackStep5,
	$MarginContainer/VBoxContainer/TrackStep6,
]

const _STEP_COLORS := [Color(0.35, 0.35, 0.35), Color.BLACK]

func _ready() -> void:
	_populate_step_colors()
	_populate_rewards()
	refresh()

# Alternates step backgrounds grey/black (independent of player state) so
# adjacent steps are easy to tell apart at a glance.
func _populate_step_colors() -> void:
	for i in _steps.size():
		_steps[i].set_background_color(_STEP_COLORS[i % _STEP_COLORS.size()])

# Shows each milestone's reward effect icon(s) at its matching TrackStep. Static per
# track (doesn't depend on player state), so this only needs to run once.
func _populate_rewards() -> void:
	var track: FactionTrackData = GameState.faction_tracks.get(faction_name, null)
	if track == null:
		return
	var effects_by_position: Dictionary = {}
	for milestone: FactionMilestone in track.milestones:
		effects_by_position[milestone.position] = milestone.effects
	for pos in range(1, _steps.size() + 1):
		var step_index: int = _steps.size() - pos
		if step_index < 0 or step_index >= _steps.size():
			continue
		_steps[step_index].set_reward_effects(effects_by_position.get(pos, []))

# Re-reads every player's position on this faction's track and shows exactly one
# marker per player who has at least 1 point — hidden entirely below that.
func refresh() -> void:
	if not GameState.faction_tracks.has(faction_name):
		return
	for step: TrackStep in _steps:
		for i in GameState.players.size():
			step.set_marker(i, false)
	for i in GameState.players.size():
		var p: PlayerState = GameState.players[i]
		var pos: int = p.rapport.get(faction_name, 0)
		if pos < 1:
			continue
		# Steps are laid out top-to-bottom in the VBoxContainer; the bottom step
		# (last in the array) is position 1, so higher positions climb upward.
		var step_index: int = _steps.size() - pos
		if step_index < 0 or step_index >= _steps.size():
			continue
		_steps[step_index].set_marker(i, true, p.player_color)
