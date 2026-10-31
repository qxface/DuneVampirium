extends GutTest

# Coverage for CardData's *_effective_auto_execute getters (see "Agent-Effect
# Resolution / auto_execute" in CLAUDE.md, [[auto-execute-effect-resolution]]):
# an effect auto-fires (via GameState.resolve_auto_actions()) only when it has no
# cost, no Requirement, and its own *_auto_execute flag is true.
#
# reveal_effective_auto_execute was widened 2026-10-30 to also check *_requirement
# (previously cost-only), per the explicit design call: "If an effect has no cost or
# requirement and just gives resources, it should default to setting 'Auto Executes'
# to true." agent_effective_auto_execute deliberately was NOT changed at the same
# time (flagged as an open parity question in CLAUDE.md, not yet decided) — this file
# locks in that current asymmetry so it isn't silently reintroduced or silently
# "fixed" without an explicit decision either way.
#
# Pure CardData.new() fixtures — no GameState/autoload involvement, no isolation
# bookkeeping needed.

func test_default_card_has_no_cost_or_requirement_and_auto_fires():
	var d := CardData.new()
	assert_true(d.reveal_effective_auto_execute)
	assert_true(d.agent_effective_auto_execute)
	assert_true(d.acquire_effective_auto_execute)

func test_reveal_cost_forces_effective_auto_execute_false():
	var d := CardData.new()
	d.reveal_cost = GameEnums.CostType.MONEY
	d.reveal_cost_amount = 2
	assert_false(d.reveal_auto_execute, "The *_cost setter should force the stored flag off too")
	assert_false(d.reveal_effective_auto_execute)

func test_reveal_cost_amount_alone_with_no_cost_type_does_not_force_it_off():
	var d := CardData.new()
	d.reveal_cost_amount = 3  # reveal_cost is still NONE
	assert_true(d.reveal_auto_execute)
	assert_true(d.reveal_effective_auto_execute)

func test_reveal_requirement_alone_forces_effective_auto_execute_false():
	# The 2026-10-30 fix: a Requirement with NO resource cost previously still read as
	# effective_auto_execute == true (getter only checked cost) — this is the exact
	# regression this test guards against. Note the *_requirement setter does NOT force
	# the stored *_auto_execute flag off the way *_cost does (only the Requirement enum
	# itself changes) — the getter is what has to catch it.
	var d := CardData.new()
	d.reveal_requirement = GameEnums.RequirementType.MONEY
	d.reveal_requirement_amount = 1
	assert_true(d.reveal_auto_execute, "Only the cost setter force-disables the stored flag, not requirement")
	assert_false(d.reveal_effective_auto_execute, "A Requirement alone must still block auto-fire")

func test_reveal_cost_and_requirement_together_force_effective_auto_execute_false():
	var d := CardData.new()
	d.reveal_cost = GameEnums.CostType.BLOOD
	d.reveal_requirement = GameEnums.RequirementType.SECRET
	assert_false(d.reveal_effective_auto_execute)

func test_reveal_auto_execute_manually_disabled_with_no_cost_or_requirement():
	# e.g. a hypothetical "Trash 1 Plan" — free, but needs player input to pick a target.
	var d := CardData.new()
	d.reveal_auto_execute = false
	assert_false(d.reveal_effective_auto_execute)

func test_reveal_cost_wins_even_if_auto_execute_is_manually_re_enabled_after():
	# Belt-and-suspenders: the stored flag CAN be flipped back on after a cost is set
	# (the cost setter only forces it off going forward, nothing stops a later manual
	# re-enable) but the effective getter re-checks cost independently every time, so a
	# costed effect can never actually auto-fire regardless of the stored checkbox.
	var d := CardData.new()
	d.reveal_cost = GameEnums.CostType.MONEY
	d.reveal_auto_execute = true  # fighting the setter's own force-off
	assert_true(d.reveal_auto_execute, "The stored flag itself can be re-flipped")
	assert_false(d.reveal_effective_auto_execute, "But the effective getter must still refuse")

func test_agent_effective_auto_execute_is_still_cost_only_not_requirement():
	# Deliberate current asymmetry (see CLAUDE.md Open Questions, 2026-10-30 entry) —
	# Agent was NOT widened alongside Reveal. If this test starts failing because
	# someone changed agent_effective_auto_execute, that's a real decision to make
	# (and document), not an accidental regression.
	var d := CardData.new()
	d.agent_requirement = GameEnums.RequirementType.MONEY
	assert_true(d.agent_effective_auto_execute, "Agent's getter does not check Requirement today")

	d.agent_cost = GameEnums.CostType.MONEY
	assert_false(d.agent_effective_auto_execute, "Agent's getter does still check cost")
