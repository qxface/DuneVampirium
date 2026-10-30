class_name Board
extends Node2D

const PANEL_MARGIN: float = 8.0  # 4 px on each side of the inner scroll area

@onready var hand_container: HBoxContainer        = %HandHBoxContainer
@onready var minion_panel: Panel                  = %MinionPanel
@onready var selected_minion_panel: Panel         = %SelectedMinionPanel
@onready var selected_plan_panel: Panel           = %SelectedPlanPanel
@onready var plan_panel: Panel                    = %PlanPanel
@onready var minion_hbox: HBoxContainer           = %MinionHBoxContainer
@onready var selected_minion_hbox: HBoxContainer  = %SelectedMinionHBoxContainer
@onready var selected_plan_hbox: HBoxContainer    = %SelectedPlanHBoxContainer
@onready var plan_hbox: HBoxContainer             = %PlanHBoxContainer

@onready var send_minions_button: LongPressButton  = %SendMinionsButton
@onready var reveal_button: LongPressButton        = %RevealButton
@onready var recall_minions_button: LongPressButton = %RecallMinionsButton
@onready var minion_reveal_button: LongPressButton = %MinionRevealButton
@onready var end_turn_button: LongPressButton      = %EndTurnButton
@onready var accept_recall_button: LongPressButton = %AcceptRecallButton
@onready var cancel_recall_button: LongPressButton = %CancelRecallButton
@onready var player_panel: Panel                   = %PlayerPanel
@onready var action_count_icon: Control             = %ActionCount
@onready var plan_deck: Control                    = %PlanDeck
@onready var plan_discard_icon: Control            = %PlanDiscard
@onready var plan_in_play_icon: Control            = %PlanInPlay
@onready var money_icon: Control                   = %MoneyResource
@onready var blood_icon: Control                   = %BloodResource
@onready var secret_icon: Control                  = %SecretResource
@onready var vp_icon: Control                       = %PlayerVP
@onready var influence_icon: Control                = %InfluenceIcon
@onready var fight_icon: Control                    = %FightIcon
@onready var undo_icon: Control                     = %UndoIcon
@onready var track_spaces_widgets: Array[TrackSpaces] = [%TrackSpaces, %TrackSpaces2, %TrackSpaces3]

var _plan_deck_long_press_active: bool = false
var _plan_discard_long_press_active: bool = false
var _plan_in_play_long_press_active: bool = false
var _undo_long_press_active: bool = false

const PLAN_SCENE   := preload("res://game_pieces/plan.tscn")
const MINION_SCENE := preload("res://game_pieces/minion.tscn")

var _cached_round: int = 0
var _recall_mode: bool = false

func _ready() -> void:
	add_to_group("BOARD")
	selected_minion_hbox.add_to_group("MINION_HOLDER")
	selected_plan_hbox.add_to_group("PLAN_HOLDER")

	# Clear hardcoded placeholder nodes from the scene.
	for node in plan_hbox.get_children():
		node.queue_free()
	for node in minion_hbox.get_children():
		node.queue_free()

	hand_container.sort_children.connect(_raise_selected_panels)
	_raise_selected_panels.call_deferred()
	_update_hand_widths.call_deferred()
	Availability.update.call_deferred()
	_sync_hand_display.call_deferred()

	plan_deck.gui_input.connect(_on_plan_deck_input)
	plan_in_play_icon.gui_input.connect(_on_plan_in_play_input)
	plan_discard_icon.gui_input.connect(_on_plan_discard_input)
	undo_icon.gui_input.connect(_on_undo_input)

	send_minions_button.long_pressed.connect(_do_place)
	reveal_button.long_pressed.connect(_do_reveal)
	recall_minions_button.long_pressed.connect(_do_recall_minions)
	end_turn_button.long_pressed.connect(_do_end_turn)
	accept_recall_button.long_pressed.connect(_do_accept_recall)
	cancel_recall_button.long_pressed.connect(_do_cancel_recall)

	# Superseded 2026-10-20: Minion Reveal activation is no longer its own
	# select-one-then-press-button flow — it's one more item in the Reveal-phase
	# PendingActionPrompt list (see _do_reveal()), alongside Plan reveal powers. The
	# MinionRevealButton node stays in board.tscn (unused) rather than edited out of the
	# scene file here; permanently hidden so it never shows.
	minion_reveal_button.visible = false

	for space in get_tree().get_nodes_in_group("SPACE"):
		space.recall_selection_changed.connect(_update_button_states)

	Availability.updated.connect(_update_button_states)
	GameState.state_changed.connect(_update_button_states)
	_update_button_states()

# ── Button state ──────────────────────────────────────────────────────────────

func _update_button_states() -> void:
	var cp    := GameState.current_player()
	var phase := cp.round_phase

	var placing  := phase == PlayerState.RoundPhase.ACTIVE

	send_minions_button.visible    = placing and not _recall_mode
	reveal_button.visible          = placing and not _recall_mode
	recall_minions_button.visible  = placing and not _recall_mode
	accept_recall_button.visible   = _recall_mode
	cancel_recall_button.visible   = _recall_mode

	send_minions_button.disabled   = not (GameState.can_place() and _has_valid_selection())
	reveal_button.disabled         = not GameState.can_reveal()
	recall_minions_button.disabled = not GameState.can_recall()
	end_turn_button.disabled       = not GameState.can_end_turn()
	accept_recall_button.disabled  = not _has_recall_selection()

	_update_plan_in_play_display()
	_update_action_display()
	_update_resource_display()
	_update_plan_deck_display()
	_update_plan_discard_display()
	_update_card_selectability()
	_update_faction_tracks()
	_update_space_occupancy_display()
	_update_undo_display()

	if GameState.round_number != _cached_round:
		_cached_round = GameState.round_number
		_sync_hand_display()
	elif plan_hbox.get_child_count() + selected_plan_hbox.get_child_count() != GameState.current_player().plan_hand.size():
		_sync_plan_hand()

func _update_card_selectability() -> void:
	var cp    := GameState.current_player()
	var phase := cp.round_phase

	var minion_selectable: bool = (phase == PlayerState.RoundPhase.ACTIVE and GameState.can_place() and not _recall_mode) \
		or (phase == PlayerState.RoundPhase.REVEALING and cp.actions_remaining > 0)
	var plan_selectable: bool = phase == PlayerState.RoundPhase.ACTIVE and GameState.can_place() and not _recall_mode

	for card in get_tree().get_nodes_in_group("MINION"):
		card.can_select = minion_selectable
		if not minion_selectable and card.selected:
			card.selected = false
	for card in get_tree().get_nodes_in_group("PLAN"):
		card.can_select = plan_selectable
		if not plan_selectable and card.selected:
			card.selected = false

func _has_valid_selection() -> bool:
	var tree := get_tree()
	var sel_minions: Array = tree.get_nodes_in_group("MINION").filter(func(n): return n.selected)
	var sel_plans:   Array = tree.get_nodes_in_group("PLAN").filter(func(n): return n.selected)
	var sel_spaces:  Array = tree.get_nodes_in_group("SPACE").filter(func(n): return n.selected)
	if sel_minions.is_empty() or sel_plans.is_empty() or sel_spaces.is_empty():
		return false
	var space: Space = sel_spaces[0]
	var minion_datas: Array = sel_minions.map(func(n): return n.card_data)
	var plan_datas:   Array = sel_plans.map(func(n): return n.card_data)
	return GameState.can_afford_place(minion_datas, plan_datas, space.space_data)

func _has_recall_selection() -> bool:
	return get_tree().get_nodes_in_group("SPACE").any(func(s): return s.recall_selected)

# ── Turn actions ──────────────────────────────────────────────────────────────

func _do_place() -> void:
	var tree := get_tree()
	var sel_minions: Array = tree.get_nodes_in_group("MINION").filter(func(n): return n.selected)
	var sel_plans:   Array = tree.get_nodes_in_group("PLAN").filter(func(n): return n.selected)
	var sel_spaces:  Array = tree.get_nodes_in_group("SPACE").filter(func(n): return n.selected)

	if sel_minions.is_empty() or sel_plans.is_empty() or sel_spaces.is_empty():
		return

	var space: Space = sel_spaces[0]
	var minion_datas: Array = sel_minions.map(func(n): return n.card_data)
	var plan_datas:   Array = sel_plans.map(func(n): return n.card_data)
	var space_data: SpaceData = space.space_data
	var description := _describe_place(minion_datas, plan_datas, space_data)
	var params := {"type": "place", "minions": minion_datas, "plans": plan_datas, "space": space_data}

	# Snapshot BEFORE any mutation — the whole Place, including whatever the player
	# chooses to trigger from the PendingActionPrompt below, is one undo-able Action.
	var pre := GameState.begin_undo_span()
	# Trace written BEFORE execute_place() runs, so even a crash inside it still leaves
	# "what was about to happen" on disk (see globals/error_tracker.gd).
	ErrorTracker.start_trace(pre, "place", description, params)
	GameState.execute_place(minion_datas, plan_datas, space_data)
	# The meeple appears automatically — execute_place()'s state_changed already ran
	# _update_space_occupancy_display() synchronously by the time this line runs.
	space.selected = false

	# Remove placed minion cards from the scene (they now live on the board as a meeple).
	for minion_node in sel_minions:
		minion_node.queue_free()

	# Remove played plan cards from the scene (they now live in the In Play panel).
	for plan_node in sel_plans:
		plan_node.queue_free()

	# Collapse selected panels immediately — queue_free is deferred so
	# _update_hand_widths would read stale child counts; zero them directly.
	# Hand Panels are SIZE_EXPAND_FILL and auto-fill the freed space.
	_set_selected_panel(selected_minion_panel, 0)
	_set_selected_panel(selected_plan_panel,   0)

	Availability.update()

	# Free Agent effects (Minions, Plans, and the Space) fire immediately; whatever's
	# left — costed, or otherwise flagged manual — goes to the player as a list to
	# trigger in whatever order they choose (an earlier choice may fund a later one).
	var pending := GameState.build_agent_pending_actions(minion_datas, plan_datas, space_data)
	pending = GameState.resolve_auto_actions(pending)
	if pending.is_empty():
		GameState.commit_action_log(pre, "place", description, params)
	else:
		# Nothing left to trigger stays pending until the player closes the prompt —
		# only then is the whole Place actually "done" for logging/undo purposes.
		PendingActionPrompt.closed.connect(
			func(): GameState.commit_action_log(pre, "place", description, params),
			CONNECT_ONE_SHOT
		)
		PendingActionPrompt.show_pending(pending)

func _do_reveal() -> void:
	# Minions mid-selection for an unsent Place action return to the ready hand —
	# Reveal abandons any in-progress Place composition.
	for node in selected_minion_hbox.get_children():
		node.selected = false

	# All Plans still in hand — including any mid-selection for an unsent Place
	# action — move to the in-play area. GameState.execute_reveal() already folds
	# both into plan_in_play, so both node groups are removed here.
	for node in plan_hbox.get_children():
		node.queue_free()
	for node in selected_plan_hbox.get_children():
		node.queue_free()
	_set_selected_panel(selected_plan_panel, 0)

	var reveal_description := "%s revealed" % GameState.current_player().player_name
	var reveal_params := {"type": "reveal"}
	var pre := GameState.begin_undo_span()
	ErrorTracker.start_trace(pre, "reveal", reveal_description, reveal_params)
	GameState.execute_reveal()

	# Corrected 2026-10-30 (was: nothing here ever auto-fires, per CLAUDE.md's 2026-10-20
	# decision) — now mirrors _do_place(): an uncosted Plan power, or an uncosted-AND-
	# zero-Action-token-cost Minion power, fires immediately with no player input;
	# anything costed in resources and/or Action tokens stays a player-triggered,
	# declinable choice in the prompt, same as before. The whole Reveal, including
	# every pending trigger the player makes from it, still stays one undo-able Action
	# until the prompt closes (same bundling pattern _do_place() uses above).
	var pending := GameState.build_reveal_pending_actions()
	pending = GameState.resolve_auto_actions(pending)
	if pending.is_empty():
		GameState.commit_action_log(pre, "reveal", reveal_description, reveal_params)
	else:
		PendingActionPrompt.closed.connect(
			func(declined: Array):
				if not declined.is_empty():
					reveal_params["declined"] = declined.map(func(i: PendingAction): return i.source)
				GameState.commit_action_log(pre, "reveal", reveal_description, reveal_params),
			CONNECT_ONE_SHOT
		)
		PendingActionPrompt.show_pending(pending)

func _do_end_turn() -> void:
	GameState.end_turn()

func _do_recall_minions() -> void:
	if not GameState.can_recall():
		return
	_recall_mode = true
	for space in get_tree().get_nodes_in_group("SPACE"):
		space.recalling = true
	_update_button_states()

func _do_accept_recall() -> void:
	var selected_spaces: Array = get_tree().get_nodes_in_group("SPACE").filter(func(s): return s.recall_selected)
	if selected_spaces.is_empty():
		return
	var minion_datas: Array = []
	var space_datas: Array = []
	for space: Space in selected_spaces:
		minion_datas.append_array(space.placed_minions())
		space_datas.append(space.space_data)

	var recall_description := _describe_recall(minion_datas)
	var recall_params := {"type": "recall", "minions": minion_datas, "spaces": space_datas}
	var pre := GameState.begin_undo_span()
	ErrorTracker.start_trace(pre, "recall", recall_description, recall_params)
	GameState.execute_recall(minion_datas, space_datas)
	# The meeples clear automatically — execute_recall()'s state_changed already ran
	# _update_space_occupancy_display() synchronously by the time this line runs.
	GameState.commit_action_log(pre, "recall", recall_description, recall_params)
	for d: CardData in minion_datas:
		var node := MINION_SCENE.instantiate()
		minion_hbox.add_child(node)
		node.card_data = d  # must be after add_child
	_exit_recall_mode()

func _do_cancel_recall() -> void:
	_exit_recall_mode()

func _exit_recall_mode() -> void:
	_recall_mode = false
	for space in get_tree().get_nodes_in_group("SPACE"):
		space.recalling = false
	_update_button_states()

# ── Hand sync ─────────────────────────────────────────────────────────────────

func _sync_hand_display() -> void:
	_sync_plan_hand()
	_sync_minion_hand()
	_cached_round = GameState.round_number
	_update_hand_widths()

func _sync_plan_hand() -> void:
	for node in plan_hbox.get_children():
		node.queue_free()
	for data: CardData in GameState.current_player().plan_hand:
		var node := PLAN_SCENE.instantiate()
		plan_hbox.add_child(node)
		node.card_data = data  # must be after add_child

func _sync_minion_hand() -> void:
	for node in minion_hbox.get_children():
		node.queue_free()
	for data: CardData in GameState.current_player().ready_minions:
		var node := MINION_SCENE.instantiate()
		minion_hbox.add_child(node)
		node.card_data = data  # must be after add_child

# ── Action count ──────────────────────────────────────────────────────────────
# The designer-placed ActionCount icon (in PlayerPanel's GridContainer) shows the
# remaining-action count directly via its base texture (action_0.png..action_6.png),
# instead of one token image per action — saves display space.

const ACTION_TOKEN_TEXTURES := [
	preload("res://assets/icons/resources/action_0.png"),
	preload("res://assets/icons/resources/action_1.png"),
	preload("res://assets/icons/resources/action_2.png"),
	preload("res://assets/icons/resources/action_3.png"),
	preload("res://assets/icons/resources/action_4.png"),
	preload("res://assets/icons/resources/action_5.png"),
	preload("res://assets/icons/resources/action_6.png"),
]

func _update_action_display() -> void:
	var remaining: int = clampi(GameState.current_player().actions_remaining, 0, ACTION_TOKEN_TEXTURES.size() - 1)
	action_count_icon.icon = ACTION_TOKEN_TEXTURES[remaining]
	action_count_icon.tags = ""

# ── Resource display ─────────────────────────────────────────────────────────

func _update_resource_display() -> void:
	var p := GameState.current_player()
	money_icon.tags  = _resource_tag(p.money)
	blood_icon.tags  = _resource_tag(p.blood)
	secret_icon.tags = _resource_tag(p.secrets)
	vp_icon.tags     = _resource_tag(p.vp)
	# Fight/Influence: real banked amount + live forecast from cards still in hand —
	# see GameState.forecast_resource_gain() for why this stays correct pre- and
	# post-Reveal without branching on round_phase here.
	var fight_total: int = p.fight + GameState.forecast_resource_gain(p, GainResource.GainType.FIGHT)
	var influence_total: int = p.influence + GameState.forecast_resource_gain(p, GainResource.GainType.INFLUENCE)
	fight_icon.tags     = _resource_tag(fight_total)
	influence_icon.tags = _resource_tag(influence_total)

func _resource_tag(amount: int) -> String:
	return "" if amount <= 0 else str(clampi(amount, 0, 99))

# ── Faction tracks ───────────────────────────────────────────────────────────

func _update_faction_tracks() -> void:
	for ts: TrackSpaces in track_spaces_widgets:
		ts.track.refresh()

# ── Board occupancy ──────────────────────────────────────────────────────────
# Space is a pure view over GameState.space_occupancy — same hub every other
# GameState-driven widget on this screen refreshes from.

func _update_space_occupancy_display() -> void:
	for space in get_tree().get_nodes_in_group("SPACE"):
		space.refresh_occupancy()

# ── Undo ──────────────────────────────────────────────────────────────────────

func _update_undo_display() -> void:
	var can_undo: bool = GameState.can_undo() and not _recall_mode
	undo_icon.modulate = Color(1, 1, 1, 1) if can_undo else Color(1, 1, 1, 0.3)

func _on_undo_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_undo_long_press_active = true
				get_tree().create_timer(0.5).timeout.connect(_on_undo_long_press_timeout)
			else:
				_undo_long_press_active = false

func _on_undo_long_press_timeout() -> void:
	if not _undo_long_press_active:
		return
	_undo_long_press_active = false
	if _recall_mode or not GameState.can_undo():
		return
	# Selection is UI-only and doesn't touch GameState data, but it may reference cards
	# whose zone is about to change wholesale — clear any in-progress Place composition
	# before the restore, same as _do_reveal() does.
	for node in selected_minion_hbox.get_children():
		node.queue_free()
	for node in selected_plan_hbox.get_children():
		node.queue_free()
	_set_selected_panel(selected_minion_panel, 0)
	_set_selected_panel(selected_plan_panel, 0)
	GameState.undo_last_action()
	_sync_hand_display()
	Availability.update()

# ── Action Log descriptions ─────────────────────────────────────────────────
# Human-readable strings frozen into each ActionLogEntry at commit time (see
# GameState.commit_action_log()) — not regenerated later, so they stay accurate even
# if the underlying cards/spaces later change (e.g. get trashed).

func _describe_place(minion_datas: Array, plan_datas: Array, space_data: SpaceData) -> String:
	var names: Array = []
	for d: CardData in minion_datas + plan_datas:
		names.append(d.card_name)
	return "%s placed %s at %s" % [GameState.current_player().player_name, ", ".join(names), space_data.space_name]

func _describe_recall(minion_datas: Array) -> String:
	if minion_datas.is_empty():
		return "%s recalled nothing" % GameState.current_player().player_name
	var names: Array = []
	for d: CardData in minion_datas:
		names.append(d.card_name)
	return "%s recalled %s" % [GameState.current_player().player_name, ", ".join(names)]

# ── Plan deck ─────────────────────────────────────────────────────────────────

func _update_plan_deck_display() -> void:
	var count := GameState.current_player().plan_draw_pile.size()
	plan_deck.tags = "" if count == 0 else ("+" if count > 9 else str(count))

func _on_plan_deck_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_plan_deck_long_press_active = true
				get_tree().create_timer(0.5).timeout.connect(_on_plan_deck_long_press_timeout)
			else:
				_plan_deck_long_press_active = false

func _on_plan_deck_long_press_timeout() -> void:
	if not _plan_deck_long_press_active:
		return
	_plan_deck_long_press_active = false
	var pile: Array[CardData] = GameState.current_player().plan_draw_pile
	if not pile.is_empty():
		CardArrayPopup.show_cards(pile, "Plan Deck")

func _update_plan_discard_display() -> void:
	var count := GameState.current_player().plan_discard.size()
	plan_discard_icon.tags = "" if count == 0 else ("+" if count > 9 else str(count))

func _on_plan_discard_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_plan_discard_long_press_active = true
				get_tree().create_timer(0.5).timeout.connect(_on_plan_discard_long_press_timeout)
			else:
				_plan_discard_long_press_active = false

func _on_plan_discard_long_press_timeout() -> void:
	if not _plan_discard_long_press_active:
		return
	_plan_discard_long_press_active = false
	var pile: Array[CardData] = GameState.current_player().plan_discard
	if not pile.is_empty():
		CardArrayPopup.show_cards(pile, "Plan Discard")

# ── Plan In Play icon ─────────────────────────────────────────────────────────

func _update_plan_in_play_display() -> void:
	var count := GameState.current_player().plan_in_play.size()
	plan_in_play_icon.tags = "" if count == 0 else ("+" if count > 9 else str(count))

func _on_plan_in_play_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_plan_in_play_long_press_active = true
				get_tree().create_timer(0.5).timeout.connect(_on_plan_in_play_long_press_timeout)
			else:
				_plan_in_play_long_press_active = false

func _on_plan_in_play_long_press_timeout() -> void:
	if not _plan_in_play_long_press_active:
		return
	_plan_in_play_long_press_active = false
	var pile: Array[CardData] = GameState.current_player().plan_in_play
	if not pile.is_empty():
		CardArrayPopup.show_cards(pile, "Plans In Play")

# Called by cards (via _request_width_update) after any selection change.
func _update_hand_widths() -> void:
	_set_selected_panel(selected_minion_panel, selected_minion_hbox.get_child_count())
	_set_selected_panel(selected_plan_panel,   selected_plan_hbox.get_child_count())

# Sets a SelectedPanel's width and visibility based on how many cards it holds.
# Hand Panels (MinionPanel / PlanPanel) are SIZE_EXPAND_FILL and fill automatically.
# SIZE_SHRINK_BEGIN (0) = no fill, no expand; child gets exactly custom_minimum_size.
func _set_selected_panel(panel: Panel, count: int) -> void:
	match count:
		0:
			panel.visible = false
			panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			panel.custom_minimum_size.x = 0
		1:
			panel.visible = true
			panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			panel.custom_minimum_size.x = Card.WIDTH + PANEL_MARGIN  # 183
		_:
			panel.visible = true
			panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			panel.custom_minimum_size.x = int(1.5 * Card.WIDTH)  # 262

# Moves the selected panels upward so their cards are fully visible on screen.
func _raise_selected_panels() -> void:
	var vh: float = get_viewport().get_visible_rect().size.y
	_align_panel_bottom(selected_minion_panel, Card.HEIGHT, vh)
	_align_panel_bottom(selected_plan_panel,   Card.HEIGHT, vh)

func _align_panel_bottom(panel: Control, card_height: float, viewport_height: float) -> void:
	var target_global_y: float = viewport_height - card_height
	panel.position.y += target_global_y - panel.global_position.y
