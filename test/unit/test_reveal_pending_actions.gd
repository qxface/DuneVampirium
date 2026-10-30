extends GutTest

# Coverage for the Reveal-phase pending-action list (CLAUDE.md 2026-10-20 decisions,
# auto-execute corrected 2026-10-30): an uncosted Plan power, or an uncosted-AND-
# zero-Action-token-cost Minion power, auto-fires via resolve_auto_actions() with no
# player input — everything else (any resource cost, Requirement, or Action-token
# cost) stays a manual, player-ordered, player-declinable pending item. Minion Reveal
# powers additionally gate on a per-card Action-token cost + repeat limit
# (reveal_max_uses, -1 = unlimited), and an Action token is just another generic
# resource (GainResource.GainType.ACTION).
#
# These tests drive the real GameState/PendingActionPrompt autoloads directly (not a
# fresh instance per test) — before_each()/after_each() snapshot and restore player 0's
# relevant fields so tests stay isolated from each other and from any real playtesting
# session running in the same editor.

var _p: PlayerState
var _saved := {}

func before_each():
	GameState.current_player_index = 0
	_p = GameState.current_player()
	_saved = {
		"plan_hand": _p.plan_hand.duplicate(),
		"ready_minions": _p.ready_minions.duplicate(),
		"plan_in_play": _p.plan_in_play.duplicate(),
		"actions_remaining": _p.actions_remaining,
		"money": _p.money,
		"round_phase": _p.round_phase,
	}
	_p.plan_hand = []
	_p.ready_minions = []
	_p.plan_in_play = []
	_p.actions_remaining = 5
	_p.money = 0
	_p.round_phase = PlayerState.RoundPhase.ACTIVE

func after_each():
	_p.plan_hand = _saved["plan_hand"]
	_p.ready_minions = _saved["ready_minions"]
	_p.plan_in_play = _saved["plan_in_play"]
	_p.actions_remaining = _saved["actions_remaining"]
	_p.money = _saved["money"]
	_p.round_phase = _saved["round_phase"]

# --- helpers -----------------------------------------------------------------

func _make_money_plan(amount: int) -> CardData:
	var d := CardData.new()
	d.card_type = CardData.CardType.PLAN
	var fx := GainResource.new()
	fx.type = GainResource.GainType.MONEY
	fx.amount = amount
	d.reveal_effects = [fx]
	return d

func _make_money_minion(amount: int, action_cost: int, max_uses: int) -> CardData:
	var d := CardData.new()
	d.card_type = CardData.CardType.MINION
	d.vampire = true  # Minions require >=1 Origin pip, per CardData's validator
	var fx := GainResource.new()
	fx.type = GainResource.GainType.MONEY
	fx.amount = amount
	d.reveal_effects = [fx]
	d.reveal_action_cost = action_cost
	d.reveal_max_uses = max_uses
	return d

# --- tests ---------------------------------------------------------------------

func test_building_the_pending_list_alone_never_fires_effects():
	# build_reveal_pending_actions() itself is a pure read — effects only fire once the
	# caller runs the result through resolve_auto_actions() (free items) or
	# try_trigger_pending() (manual items). This holds even for an uncosted Plan, whose
	# power WOULD auto-fire once resolve_auto_actions() actually runs — see
	# test_uncosted_plan_reveal_auto_fires_via_resolve_auto_actions() below.
	var plan := _make_money_plan(3)
	_p.plan_hand = [plan]

	GameState.execute_reveal()
	assert_eq(_p.money, 0, "Reveal alone must not fire any Plan's reveal effect")
	assert_true(_p.plan_in_play.has(plan), "Reveal should still move the Plan to in-play")

	var pending := GameState.build_reveal_pending_actions()
	assert_eq(pending.size(), 1, "One pending item for the one revealed Plan")
	assert_eq(_p.money, 0, "Building the list alone must not fire anything either")

	assert_true(GameState.try_trigger_pending(pending[0]))
	assert_eq(_p.money, 3, "Manually triggering the pending item should fire its effect")

func test_uncosted_plan_reveal_auto_fires_via_resolve_auto_actions():
	# A Plan with no reveal_cost and no reveal_requirement (the default, see
	# _make_money_plan()) is effective_auto_execute — board.gd runs the pending list
	# through resolve_auto_actions() before ever showing a prompt, so it fires with no
	# player input (corrected 2026-10-30; see CLAUDE.md Key Decisions Log).
	var plan := _make_money_plan(3)
	_p.plan_hand = [plan]

	GameState.execute_reveal()
	var pending := GameState.build_reveal_pending_actions()
	pending = GameState.resolve_auto_actions(pending)

	assert_eq(_p.money, 3, "Uncosted Plan power should have fired automatically")
	assert_true(pending.is_empty(), "Nothing manual left for the player to trigger")

func test_zero_action_cost_minion_reveal_auto_fires_via_resolve_auto_actions():
	# A Minion whose reveal power costs 0 Action tokens and has no resource cost or
	# Requirement also auto-fires — e.g. a Minion that just hands out a free Action
	# token for another Minion to spend (see CLAUDE.md 2026-10-20 decisions).
	var minion := _make_money_minion(2, 0, 1)  # 0 Action-token cost, usable once
	_p.ready_minions = [minion]

	GameState.execute_reveal()
	var pending := GameState.build_reveal_pending_actions()
	pending = GameState.resolve_auto_actions(pending)

	assert_eq(_p.money, 2, "Zero-Action-cost Minion power should have fired automatically")
	assert_true(pending.is_empty(), "Nothing manual left for the player to trigger")

func test_costed_minion_reveal_power_stays_manual_through_resolve_auto_actions():
	# A positive Action-token cost always keeps the item manual/pending, even though
	# resolve_auto_actions() runs on the whole list — spending a token is a real choice.
	var minion := _make_money_minion(5, 1, 1)  # costs 1 Action token
	_p.ready_minions = [minion]
	_p.actions_remaining = 5

	GameState.execute_reveal()
	var pending := GameState.build_reveal_pending_actions()
	pending = GameState.resolve_auto_actions(pending)

	assert_eq(_p.money, 0, "Costed Minion power must not auto-fire")
	assert_eq(pending.size(), 1, "It should stay in the manual pending list")
	assert_true(GameState.try_trigger_pending(pending[0]))
	assert_eq(_p.money, 5)

func test_minion_reveal_gated_by_action_token_affordability():
	var minion := _make_money_minion(5, 2, 1)  # costs 2 Action tokens, usable once
	_p.ready_minions = [minion]
	_p.actions_remaining = 1  # not enough

	GameState.execute_reveal()
	var item := GameState.build_reveal_pending_actions()[0]

	assert_false(GameState.try_trigger_pending(item), "Should refuse — not enough Action tokens")
	assert_eq(_p.money, 0)
	assert_eq(_p.actions_remaining, 1, "A failed trigger must not spend anything")

	_p.actions_remaining = 2
	assert_true(GameState.try_trigger_pending(item))
	assert_eq(_p.money, 5)
	assert_eq(_p.actions_remaining, 0)

func test_minion_reveal_max_uses_limits_repeat_triggers():
	var minion := _make_money_minion(1, 1, 2)  # costs 1, usable twice
	_p.ready_minions = [minion]
	_p.actions_remaining = 5

	GameState.execute_reveal()
	var item := GameState.build_reveal_pending_actions()[0]

	assert_true(GameState.try_trigger_pending(item))
	assert_true(item.can_use_again())
	assert_true(GameState.try_trigger_pending(item))
	assert_false(item.can_use_again(), "Second use should exhaust max_uses = 2")

	assert_false(GameState.try_trigger_pending(item), "A third trigger must be refused")
	assert_eq(_p.money, 2, "Only 2 successful triggers should have fired")
	assert_eq(_p.actions_remaining, 3)

func test_minion_reveal_unlimited_uses_bounded_only_by_affordability():
	var minion := _make_money_minion(1, 1, -1)  # costs 1, unlimited uses
	_p.ready_minions = [minion]
	_p.actions_remaining = 3

	GameState.execute_reveal()
	var item := GameState.build_reveal_pending_actions()[0]

	for _i in 3:
		assert_true(GameState.try_trigger_pending(item))
	assert_true(item.can_use_again(), "max_uses = -1 should never report exhausted")

	assert_false(GameState.try_trigger_pending(item), "Out of Action tokens, even though max_uses is unlimited")
	assert_eq(_p.money, 3)
	assert_eq(_p.actions_remaining, 0)

func test_action_token_gain_type_feeds_actions_remaining():
	_p.actions_remaining = 0
	var fx := GainResource.new()
	fx.type = GainResource.GainType.ACTION
	fx.amount = 2
	fx.trigger(GameState, null)
	assert_eq(_p.actions_remaining, 2, "GainResource.GainType.ACTION should add to actions_remaining")

func test_action_token_gained_mid_reveal_funds_another_pending_item():
	var minion := _make_money_minion(5, 1, 1)
	_p.ready_minions = [minion]
	_p.actions_remaining = 0  # can't afford the Minion's Reveal power yet

	GameState.execute_reveal()
	var item := GameState.build_reveal_pending_actions()[0]
	assert_false(GameState.try_trigger_pending(item), "Not affordable before the token gain")

	# Simulate a separate pending item (e.g. a Plan) granting an Action token mid-Reveal.
	var fx := GainResource.new()
	fx.type = GainResource.GainType.ACTION
	fx.amount = 1
	fx.trigger(GameState, null)

	assert_true(GameState.try_trigger_pending(item), "Now affordable thanks to the mid-Reveal gain")
	assert_eq(_p.money, 5)

func test_declined_items_reported_when_prompt_closes():
	var plan := _make_money_plan(1)
	var minion := _make_money_minion(1, 1, 1)
	_p.plan_hand = [plan]
	_p.ready_minions = [minion]

	GameState.execute_reveal()
	var pending := GameState.build_reveal_pending_actions()
	assert_eq(pending.size(), 2)

	watch_signals(PendingActionPrompt)
	PendingActionPrompt.show_pending(pending)
	# Trigger only the Plan's item; leave the Minion's item untouched.
	var plan_item: PendingAction = pending.filter(func(i): return i.source == plan)[0]
	PendingActionPrompt._on_trigger_pressed(plan_item)
	PendingActionPrompt.close()

	assert_signal_emitted(PendingActionPrompt, "closed")
	var call_params = get_signal_parameters(PendingActionPrompt, "closed")
	var declined: Array = call_params[0]
	assert_eq(declined.size(), 1, "Only the untouched Minion item should be reported as declined")
	assert_eq(declined[0].source, minion)
