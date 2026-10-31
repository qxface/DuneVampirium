extends GutTest

# Coverage for GameState's Undo/Action-Log engine (see globals/game_state.gd's
# "--- Undo / Action Log ---" section): can_undo()'s turn-scoping and binding-block,
# commit_action_log() emitting state_changed (fixed 2026-10-30 — the Undo icon's
# enabled display used to sit stale after a commit until some unrelated action
# refreshed it; see CLAUDE.md Key Decisions Log), and undo_last_action() actually
# restoring state and popping the log entry.
#
# Drives the real GameState/PlayerState autoloads directly, like
# test_reveal_pending_actions.gd — before_each()/after_each() snapshot and restore
# everything these tests touch (including the private _turn_log_start_index, read
# directly since GDScript has no real access control) so they stay isolated from
# real playtesting sessions and from each other.

var _p: PlayerState
var _saved := {}
var _saved_log: Array
var _saved_turn_start: int
var _saved_gentlemans_undo: bool

func before_each():
	GameState.current_player_index = 0
	_p = GameState.current_player()
	_saved = {
		"money": _p.money,
		"actions_remaining": _p.actions_remaining,
		"plan_hand": _p.plan_hand.duplicate(),
		"plan_in_play": _p.plan_in_play.duplicate(),
		"plan_draw_pile": _p.plan_draw_pile.duplicate(),
		"round_phase": _p.round_phase,
	}
	_saved_log = GameState.action_log.duplicate()
	_saved_turn_start = GameState._turn_log_start_index
	_saved_gentlemans_undo = GameState.gentlemans_undo

	GameState.action_log = []
	GameState._turn_log_start_index = 0
	GameState.gentlemans_undo = false
	_p.money = 0
	_p.actions_remaining = 5
	_p.plan_hand = []
	_p.plan_in_play = []
	_p.round_phase = PlayerState.RoundPhase.ACTIVE

func after_each():
	_p.money = _saved["money"]
	_p.actions_remaining = _saved["actions_remaining"]
	_p.plan_hand = _saved["plan_hand"]
	_p.plan_in_play = _saved["plan_in_play"]
	_p.plan_draw_pile = _saved["plan_draw_pile"]
	_p.round_phase = _saved["round_phase"]
	GameState.action_log = _saved_log
	GameState._turn_log_start_index = _saved_turn_start
	GameState.gentlemans_undo = _saved_gentlemans_undo

# --- helpers -----------------------------------------------------------------

func _draw_plan() -> CardData:
	# A free (no cost, no requirement) Plan whose only Reveal effect is DrawCard —
	# effective_auto_execute is true (nothing costed), so resolve_auto_actions() fires
	# it with no player input, which is exactly how a real binding action gets logged
	# without needing a PendingActionPrompt round-trip in these tests.
	var d := CardData.new()
	d.card_type = CardData.CardType.PLAN
	d.reveal_effects = [DrawCard.new()]
	return d

# --- can_undo() ----------------------------------------------------------------

func test_cannot_undo_with_nothing_logged_this_turn():
	assert_false(GameState.can_undo(), "Nothing committed this turn yet")

func test_can_undo_after_a_committed_non_binding_action():
	var pre := GameState.begin_undo_span()
	_p.money = 5
	GameState.commit_action_log(pre, "test", "test action", {})
	assert_true(GameState.can_undo())

func test_commit_action_log_emits_state_changed():
	# Fixed 2026-10-30: commit_action_log() previously appended to action_log without
	# emitting state_changed, so board.gd's Undo icon display could stay stale/dimmed
	# until some unrelated later action happened to refresh it.
	watch_signals(GameState)
	var pre := GameState.begin_undo_span()
	GameState.commit_action_log(pre, "test", "test action", {})
	assert_signal_emitted(GameState, "state_changed")

func test_undo_is_scoped_to_the_current_turn():
	# An action committed before the current turn started (_turn_log_start_index) must
	# not be undoable — Undo never reaches back into a previous turn's actions.
	var pre := GameState.begin_undo_span()
	_p.money = 3
	GameState.commit_action_log(pre, "test", "test action", {})
	assert_true(GameState.can_undo())

	GameState._turn_log_start_index = GameState.action_log.size()  # simulate a turn boundary
	assert_false(GameState.can_undo(), "An action from a prior turn must not be undoable")
	assert_false(GameState.undo_last_action())
	assert_eq(_p.money, 3, "A refused undo must not touch state")

func test_binding_action_blocks_undo_unless_gentlemans_undo():
	var plan := _draw_plan()
	_p.plan_hand = [plan]

	var pre := GameState.begin_undo_span()
	GameState.execute_reveal()
	var pending := GameState.resolve_auto_actions(GameState.build_reveal_pending_actions())
	assert_true(pending.is_empty(), "The free draw should have auto-fired, nothing left pending")
	GameState.commit_action_log(pre, "reveal", "test reveal", {})

	assert_false(GameState.can_undo(), "A binding (card-draw) action must refuse Undo by default")
	assert_false(GameState.undo_last_action())

	GameState.gentlemans_undo = true
	assert_true(GameState.can_undo(), "gentlemans_undo should override the binding block")
	assert_true(GameState.undo_last_action())

func test_non_binding_action_after_a_binding_one_is_independently_undoable():
	# can_undo() only looks at the LAST entry — an earlier binding action shouldn't
	# poison undo for a later, non-binding one in the same turn.
	var plan := _draw_plan()
	_p.plan_hand = [plan]
	var pre1 := GameState.begin_undo_span()
	GameState.execute_reveal()
	GameState.resolve_auto_actions(GameState.build_reveal_pending_actions())
	GameState.commit_action_log(pre1, "reveal", "test reveal", {})
	assert_false(GameState.can_undo())

	var pre2 := GameState.begin_undo_span()
	_p.money = 9
	GameState.commit_action_log(pre2, "test", "second action", {})
	assert_true(GameState.can_undo(), "The second, non-binding action should be independently undoable")

# --- undo_last_action() ---------------------------------------------------------

func test_undo_restores_pre_action_state_and_pops_the_log_entry():
	var pre := GameState.begin_undo_span()
	_p.money = 7
	GameState.commit_action_log(pre, "test", "test action", {})
	assert_eq(GameState.action_log.size(), 1)

	assert_true(GameState.undo_last_action())
	assert_eq(_p.money, 0, "Undo should restore money to its pre-action value")
	assert_eq(GameState.action_log.size(), 0, "The entry should be popped, not kept as an 'undone' record")

func test_undo_refuses_when_nothing_to_undo():
	assert_false(GameState.undo_last_action())
