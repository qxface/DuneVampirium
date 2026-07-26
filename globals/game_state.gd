extends Node

signal state_changed

const PLAYER_COUNT: int = 4
const HAND_SIZE:    int = 5

# --- Faction Tracks ---
# faction_tracks: registered FactionTrackData resources, keyed by faction_name.
# _faction_leaders: which player_index currently holds each faction's leader VP
#   (-1 = no player has reached leader_vp_position yet on that track).
# All .tres files in data/faction_tracks/ are auto-loaded at startup — no code
# changes needed when a new faction track is added; just drop a new .tres in the
# folder and it becomes available. At game setup (not yet built), the active
# faction subset will be selected from this full pool.
var faction_tracks: Dictionary = {}
var _faction_leaders: Dictionary = {}

const _FACTION_TRACKS_DIR := "res://data/faction_tracks/"

const _STARTING_PLANS := [
	preload("res://data/plans/bodice_ripping_catfight.tres"),
	preload("res://data/plans/feed.tres"),
	preload("res://data/plans/campaign.tres"),
]
const _STARTING_PLAN_COPIES: int = 3

const _PLAYER_COLORS := [
	Color.GREEN,
	Color.YELLOW,
	Color.ORANGE,
	Color.RED,
]

const _STARTING_MINIONS := [
	preload("res://data/minions/frightened_human.tres"),
	preload("res://data/minions/primori_newblood.tres"),
	preload("res://data/minions/volupta_newblood.tres"),
	preload("res://data/minions/vorace_newblood.tres"),
]

var players: Array[PlayerState] = []
var current_player_index: int = 0
var round_number: int = 1

var _action_taken_this_turn: bool = false

func _ready() -> void:
	_load_all_faction_tracks()
	for i in PLAYER_COUNT:
		var p := PlayerState.new()
		p.player_name = "Player %d" % (i + 1)
		p.is_ai = i > 0
		p.player_color = _PLAYER_COLORS[i % _PLAYER_COLORS.size()]
		for plan: CardData in _STARTING_PLANS:
			for _j in _STARTING_PLAN_COPIES:
				p.plan_draw_pile.append(plan)
		p.plan_draw_pile.shuffle()
		for minion: CardData in _STARTING_MINIONS:
			p.ready_minions.append(minion)
		players.append(p)
	# Deal opening hands.
	for p: PlayerState in players:
		draw_plans(p, HAND_SIZE)
		# TEST: seed discard with 3 random cards so the discard pile UI is exercisable.
		for _i in 3:
			p.plan_discard.append(_STARTING_PLANS[randi() % _STARTING_PLANS.size()])

func _load_all_faction_tracks() -> void:
	var dir := DirAccess.open(_FACTION_TRACKS_DIR)
	if dir == null:
		push_warning("GameState: faction_tracks directory not found: %s" % _FACTION_TRACKS_DIR)
		return
	dir.list_dir_begin()
	var filename := dir.get_next()
	while filename != "":
		if filename.ends_with(".tres"):
			var path := _FACTION_TRACKS_DIR + filename
			var res := ResourceLoader.load(path)
			if res is FactionTrackData:
				var track := res as FactionTrackData
				if track.faction_name.is_empty():
					push_warning("GameState: FactionTrackData at %s has no faction_name — skipped" % path)
				else:
					faction_tracks[track.faction_name] = track
					_faction_leaders[track.faction_name] = -1
			else:
				push_warning("GameState: %s is not a FactionTrackData — skipped" % path)
		filename = dir.get_next()
	dir.list_dir_end()

func current_player() -> PlayerState:
	return players[current_player_index]

func get_current_player() -> PlayerState:
	return players[current_player_index]

# --- Query ---

func can_place() -> bool:
	var p := current_player()
	return p.round_phase == PlayerState.RoundPhase.ACTIVE \
		and not _action_taken_this_turn \
		and p.actions_remaining > 0

func can_reveal() -> bool:
	var p := current_player()
	return p.round_phase == PlayerState.RoundPhase.ACTIVE and not _action_taken_this_turn

func can_minion_reveal() -> bool:
	var p := current_player()
	return p.round_phase == PlayerState.RoundPhase.REVEALING and p.actions_remaining > 0

func can_recall() -> bool:
	var p := current_player()
	return p.round_phase == PlayerState.RoundPhase.ACTIVE \
		and not _action_taken_this_turn \
		and p.actions_remaining > 0 \
		and not p.placed_minions.is_empty()

func can_end_turn() -> bool:
	return _action_taken_this_turn

# --- Actions ---

func execute_place(minion_datas: Array, plan_datas: Array, space_data: SpaceData) -> void:
	var p := current_player()
	p.actions_remaining -= 1
	for d: CardData in minion_datas:
		p.ready_minions.erase(d)
		p.placed_minions.append(d)
	for d: CardData in plan_datas:
		p.plan_hand.erase(d)
		p.plan_in_play.append(d)
	_spend(p, total_agent_cost(minion_datas, plan_datas, space_data))
	_action_taken_this_turn = true
	state_changed.emit()
	# Agent-effect resolution (auto-fire free effects, queue costed/manual ones for the
	# player to trigger in any order) is driven separately — see build_agent_pending_actions().

# --- Cost / affordability ---

# The mandatory toll to send minion_datas/plan_datas to space_data: the cost of whichever
# SpaceRequirement clause the selection matches. Does NOT include any card's or the Space's
# own agent_cost — those are per-Agent-action costs resolved via the pending-action flow
# (see build_agent_pending_actions()/try_trigger_pending()), since a costed Agent effect may
# be paid for using resources granted by another effect in the same Place, in whatever order
# the player chooses — it can't be bundled into a single upfront toll.
func total_agent_cost(minion_datas: Array, plan_datas: Array, space_data: SpaceData) -> Dictionary:
	var totals: Dictionary = {}
	var clause := matched_clause(minion_datas, plan_datas, space_data)
	if clause != null:
		_add_cost(totals, clause.cost_type, clause.cost_amount)
	return totals

# The first requirement_clauses entry (in order) whose pips are satisfied by the
# selection, whose requirement_type/amount the player meets, and whose cost_type/amount
# the player can afford. Null if space_data has no clauses (open Space) or none qualify.
func matched_clause(minion_datas: Array, plan_datas: Array, space_data: SpaceData) -> SpaceRequirement:
	if space_data == null or space_data.requirement_clauses.is_empty():
		return null
	var p := current_player()
	for clause: SpaceRequirement in space_data.requirement_clauses:
		if clause == null:
			continue
		if not clause.is_satisfied_by(minion_datas, plan_datas):
			continue
		if not meets_requirement(p, clause.requirement_type, clause.requirement_amount):
			continue
		if not can_afford(p, {clause.cost_type: clause.cost_amount} if clause.cost_type != GameEnums.CostType.NONE else {}):
			continue
		return clause
	return null

# Whether player holds at least `amount` of req_type. MONEY/BLOOD/SECRET read straight
# off PlayerState; PRIMORI/VOLUPTA/VORACE read player.rapport (keyed by lowercase clan name).
func meets_requirement(player: PlayerState, req_type: GameEnums.RequirementType, amount: int) -> bool:
	if req_type == GameEnums.RequirementType.NONE or amount <= 0:
		return true
	match req_type:
		GameEnums.RequirementType.MONEY:  return player.money  >= amount
		GameEnums.RequirementType.BLOOD:  return player.blood  >= amount
		GameEnums.RequirementType.SECRET: return player.secrets >= amount
		GameEnums.RequirementType.PRIMORI: return player.rapport.get("primori", 0) >= amount
		GameEnums.RequirementType.VOLUPTA: return player.rapport.get("volupta", 0) >= amount
		GameEnums.RequirementType.VORACE:  return player.rapport.get("vorace", 0)  >= amount
	return false

func can_afford(player: PlayerState, costs: Dictionary) -> bool:
	for cost_type in costs:
		var amount: int = costs[cost_type]
		match cost_type:
			GameEnums.CostType.MONEY:
				if player.money < amount:
					return false
			GameEnums.CostType.BLOOD:
				if player.blood < amount:
					return false
			GameEnums.CostType.SECRET:
				if player.secrets < amount:
					return false
			_:
				push_warning("Unsupported cost type in can_afford: %s" % GameEnums.CostType.keys()[cost_type])
				return false
	return true

func can_afford_place(minion_datas: Array, plan_datas: Array, space_data: SpaceData) -> bool:
	return can_afford(current_player(), total_agent_cost(minion_datas, plan_datas, space_data))

func _add_cost(totals: Dictionary, cost_type: GameEnums.CostType, amount: int) -> void:
	if cost_type == GameEnums.CostType.NONE or amount <= 0:
		return
	totals[cost_type] = totals.get(cost_type, 0) + amount

func _spend(player: PlayerState, costs: Dictionary) -> void:
	for cost_type in costs:
		var amount: int = costs[cost_type]
		match cost_type:
			GameEnums.CostType.MONEY:  player.money   -= amount
			GameEnums.CostType.BLOOD:  player.blood   -= amount
			GameEnums.CostType.SECRET: player.secrets -= amount

# --- Agent-effect resolution (auto-execute engine) ---
#
# Agent effects from every selected Minion, Plan, and the Space itself all trigger
# together off one Place — and per design, they can be resolved in ANY order the player
# likes, because a costed effect's cost might be paid for by a resource another effect in
# the same batch grants. So resolution happens in two passes:
#   1. build_agent_pending_actions() + resolve_auto_actions() — every action with no cost
#      (CardData/SpaceData.*_effective_auto_execute == true) fires immediately, for free.
#   2. Whatever's left (costed, or manually flagged non-auto for another reason, e.g. an
#      effect that needs player input) is returned as a queue of PendingAction — the caller
#      (board.gd) presents these for the player to trigger one at a time, in any order, via
#      try_trigger_pending(). Each attempt is checked against the player's CURRENT resources,
#      so an earlier choice can fund a later one.
# This same PendingAction/resolve_auto_actions/try_trigger_pending trio is written generically
# (keyed only on cost/effects/auto_execute, not on which lifecycle action they came from) so
# Acquire/Reveal/Discard/Trash can reuse it once those flows exist — only Place's Agent trigger
# is actually wired through it today, since it's the only place multiple cards' effects fire
# as one batch.
func build_agent_pending_actions(minion_datas: Array, plan_datas: Array, space_data: SpaceData) -> Array[PendingAction]:
	var items: Array[PendingAction] = []
	for d: CardData in minion_datas:
		if not d.agent_effects.is_empty():
			items.append(_make_pending_action(d, "Agent", d.agent_cost, d.agent_cost_amount, d.agent_effects, d.agent_effective_auto_execute))
	for d: CardData in plan_datas:
		if not d.agent_effects.is_empty():
			items.append(_make_pending_action(d, "Agent", d.agent_cost, d.agent_cost_amount, d.agent_effects, d.agent_effective_auto_execute))
	if space_data != null and not space_data.agent_effects.is_empty():
		items.append(_make_pending_action(space_data, "Agent", space_data.agent_cost, space_data.agent_cost_amount, space_data.agent_effects, space_data.agent_effective_auto_execute))
	return items

func _make_pending_action(source: Resource, action_name: String, cost_type: GameEnums.CostType, cost_amount: int, effects: Array, effective_auto_execute: bool) -> PendingAction:
	var item := PendingAction.new()
	item.source = source
	item.action_name = action_name
	item.cost_type = cost_type
	item.cost_amount = cost_amount
	item.effects = effects
	item.effective_auto_execute = effective_auto_execute
	return item

# Fires every free (effective_auto_execute) item immediately and returns the rest —
# costed or otherwise manual — for the player to resolve one at a time.
func resolve_auto_actions(items: Array[PendingAction]) -> Array[PendingAction]:
	var pending: Array[PendingAction] = []
	for item: PendingAction in items:
		if item.effective_auto_execute:
			_trigger_effects(item.effects, item.source)
		else:
			pending.append(item)
	state_changed.emit()
	return pending

# Attempts to pay item's cost (if any) and fire its effects. Returns false without
# changing anything if the player can't currently afford it.
func try_trigger_pending(item: PendingAction) -> bool:
	var p := current_player()
	if item.has_cost():
		if not can_afford(p, {item.cost_type: item.cost_amount}):
			return false
		_spend(p, {item.cost_type: item.cost_amount})
	_trigger_effects(item.effects, item.source)
	state_changed.emit()
	return true

func _trigger_effects(effects: Array, source: Resource) -> void:
	for effect: Effect in effects:
		effect.trigger(self, source)

func execute_reveal() -> void:
	var p := current_player()
	var hand_plans := p.plan_hand.duplicate()
	# Move hand plans to in-play FIRST — reveal effects may key off in-play count.
	p.plan_in_play.append_array(hand_plans)
	p.plan_hand.clear()
	# Now trigger reveal effects in hand order.
	for d: CardData in hand_plans:
		for effect: Effect in d.reveal_effects:
			effect.trigger(self, d)
	p.round_phase = PlayerState.RoundPhase.REVEALING
	_action_taken_this_turn = true
	state_changed.emit()

func execute_minion_reveal(minion_data: CardData) -> void:
	var p := current_player()
	for effect: Effect in minion_data.reveal_effects:
		effect.trigger(self, minion_data)
	p.actions_remaining -= 1
	state_changed.emit()

func execute_recall(minion_datas: Array) -> void:
	var p := current_player()
	p.actions_remaining -= 1
	for d: CardData in minion_datas:
		p.placed_minions.erase(d)
		p.ready_minions.append(d)
	_action_taken_this_turn = true
	state_changed.emit()

func end_turn() -> void:
	if current_player().round_phase == PlayerState.RoundPhase.REVEALING:
		current_player().round_phase = PlayerState.RoundPhase.DONE
	_action_taken_this_turn = false
	_advance_player()

# --- Internal ---

func _advance_player() -> void:
	for i in PLAYER_COUNT:
		var idx: int = (current_player_index + 1 + i) % PLAYER_COUNT
		var p := players[idx]
		if p.round_phase != PlayerState.RoundPhase.DONE and not p.is_ai:
			current_player_index = idx
			state_changed.emit()
			return
	_end_round()

func _end_round() -> void:
	round_number += 1
	for p: PlayerState in players:
		p.round_phase = PlayerState.RoundPhase.ACTIVE
		p.actions_remaining = p.actions_per_round
		# Discard all in-play plans (both placed and revealed).
		p.plan_discard.append_array(p.plan_in_play)
		p.plan_in_play.clear()
		# Draw a new hand (reshuffle discard into draw pile if needed, excluding in-play).
		draw_plans(p, HAND_SIZE)
	current_player_index = 0
	_action_taken_this_turn = false
	state_changed.emit()

func draw_plans(p: PlayerState, count: int) -> void:
	for _i in count:
		if p.plan_draw_pile.is_empty():
			if p.plan_discard.is_empty():
				return  # No cards anywhere — draw as many as possible.
			p.plan_draw_pile = p.plan_discard.duplicate()
			p.plan_discard.clear()
			p.plan_draw_pile.shuffle()
		p.plan_hand.append(p.plan_draw_pile.pop_back())
	state_changed.emit()

# --- Faction Track Engine ---
#
# Moves `player` by `amount` steps (positive or negative) on the named faction track,
# clamped to [0, max_position].
# - Advancing (amount > 0) fires fixed milestone effects for every position crossed
#   or landed on. Retreating (amount < 0) never fires milestones — moving back up
#   across a position re-fires its milestone, so a player can retreat and re-advance
#   to collect the same reward repeatedly.
# - After any change, re-checks the contested leader VP for this track (see
#   _check_faction_leader) — advancing past the current leader steals it; the current
#   leader retreating below another qualifying player also hands it over immediately.
# - Emits state_changed once at the end.
func advance_faction_track(player: PlayerState, faction_name: String, amount: int = 1) -> void:
	var track: FactionTrackData = faction_tracks.get(faction_name, null)
	if track == null:
		push_warning("advance_faction_track: no track registered for '%s'" % faction_name)
		return
	var old_pos: int = player.rapport.get(faction_name, 0)
	var new_pos: int = clampi(old_pos + amount, 0, track.max_position)
	if new_pos == old_pos:
		return  # Already capped/floored, or amount was 0.
	player.rapport[faction_name] = new_pos
	if new_pos > old_pos:
		# Fire every milestone whose position was crossed (old_pos < pos <= new_pos).
		for milestone: FactionMilestone in track.milestones:
			if milestone.position > old_pos and milestone.position <= new_pos:
				_trigger_effects(milestone.effects, track)
	if track.leader_vp_position > 0:
		_check_faction_leader(faction_name, player)
	state_changed.emit()

# Handles the contested leader VP for the given faction after `player`'s position
# changes (up or down):
# - If `player` isn't the current leader: steals the VP only if their position now
#   strictly exceeds the current leader's and meets leader_vp_position. Ties keep
#   the VP with the first-to-reach holder.
# - If `player` IS the current leader (this fires on their retreat too): checks
#   whether any other player's position now strictly exceeds player's new position,
#   and if so hands the VP to whichever of them holds the highest position (first
#   in player order breaks ties). If nobody exceeds them, the leader keeps the VP
#   even if they've dropped below the threshold themselves — only being surpassed
#   loses it.
func _check_faction_leader(faction_name: String, player: PlayerState) -> void:
	var track: FactionTrackData = faction_tracks[faction_name]
	var current_leader_idx: int = _faction_leaders.get(faction_name, -1)
	var player_idx: int = _get_player_index(player)
	var player_pos: int = player.rapport.get(faction_name, 0)

	if current_leader_idx == player_idx:
		var challenger_idx: int = -1
		var challenger_pos: int = -1
		for i in players.size():
			if i == player_idx:
				continue
			var pos: int = players[i].rapport.get(faction_name, 0)
			if pos > player_pos and pos > challenger_pos:
				challenger_idx = i
				challenger_pos = pos
		if challenger_idx >= 0:
			player.vp -= 1
			players[challenger_idx].vp += 1
			_faction_leaders[faction_name] = challenger_idx
			print_debug("[%s] loses leader VP on %s track to [%s]" % [player.player_name, faction_name, players[challenger_idx].player_name])
		return

	if player_pos < track.leader_vp_position:
		return  # Doesn't meet the threshold to contend.
	if current_leader_idx >= 0:
		var leader_pos: int = players[current_leader_idx].rapport.get(faction_name, 0)
		if player_pos <= leader_pos:
			return  # Tied or below — first-to-reach keeps the VP.
		# New player is strictly higher: steal the leader VP.
		players[current_leader_idx].vp -= 1
		print_debug("[%s] loses leader VP on %s track" % [players[current_leader_idx].player_name, faction_name])
	# Award leader VP to this player.
	player.vp += 1
	_faction_leaders[faction_name] = player_idx
	print_debug("[%s] takes leader VP on %s track (position %d)" % [player.player_name, faction_name, player_pos])

func _get_player_index(player: PlayerState) -> int:
	for i in players.size():
		if players[i] == player:
			return i
	return -1
