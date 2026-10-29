extends GutTest

# Smoke test only: confirms the GUT framework itself is wired up and running
# before any real feature tests are written. Delete or replace once real
# coverage exists for Reveal-phase pending actions, etc.

func test_gut_framework_runs():
	assert_true(true, "GUT ran this assertion, so the framework is working.")

func test_can_reach_game_state_autoload():
	# Sanity check that autoloads are reachable from a test context too,
	# since the real tests will need GameState/PlayerState directly.
	assert_not_null(GameState, "GameState autoload should be reachable from tests.")
