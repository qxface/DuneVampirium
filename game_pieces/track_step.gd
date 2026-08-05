class_name TrackStep
extends Panel

@onready var _markers: Array[TextureRect] = [%TextureRect1, %TextureRect2, %TextureRect3, %TextureRect4]
@onready var _reward_container: HBoxContainer = %RewardContainer
@onready var _reward_panel: Panel = $RewardContainer/Reward
@onready var _marker_panels: Array[Panel] = [
	$RewardContainer/MarkerContainer/Player1Marker,
	$RewardContainer/MarkerContainer/Player2Marker,
	$RewardContainer/MarkerContainer/Player3Marker,
	$RewardContainer/MarkerContainer/Player4Marker,
]

func _ready() -> void:
	for m: TextureRect in _markers:
		m.visible = false
		m.get_parent().visible = false

# Hides the marker's parent PlayerXMarker panel along with the TextureRect itself,
# so a row with no markers showing doesn't reserve horizontal space for them —
# only panels with a visible icon take up room in the HBoxContainer.
func set_marker(player_index: int, marker_visible: bool, color: Color = Color.WHITE) -> void:
	if player_index < 0 or player_index >= _markers.size():
		return
	var m: TextureRect = _markers[player_index]
	m.visible = marker_visible
	m.get_parent().visible = marker_visible
	if marker_visible:
		m.modulate = color

# Shows one icon per effect this step's milestone grants (empty array clears the row).
func set_reward_effects(effects: Array) -> void:
	for child in _reward_container.get_children():
		child.free()
	for effect: Effect in effects:
		if effect == null:
			continue
		var tex: Texture2D = effect.get_icon()
		if tex != null:
			ActionDisplay.add_effect_icon(_reward_container, tex, effect.get_tags())

# Applies a per-instance background color to this row — the TrackStep panel itself
# plus the Reward and player-marker panels inside it, since those opaque child panels
# would otherwise fully cover the root panel's own background. Uses fresh StyleBoxFlat
# overrides rather than touching the shared sub-resources baked into track_step.tscn,
# since PackedScene sub-resources are shared across every instance of this scene by
# default.
func set_background_color(color: Color) -> void:
	_apply_panel_color(self, color)
	_apply_panel_color(_reward_panel, color)
	for p: Panel in _marker_panels:
		_apply_panel_color(p, color)

func _apply_panel_color(panel: Panel, color: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	panel.add_theme_stylebox_override("panel", sb)
