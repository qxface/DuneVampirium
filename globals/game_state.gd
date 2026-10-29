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

# Which starting deck/roster every player begins with — a single hardcoded default
# config for now (see data/starting_deck/starting_deck_config.gd for the full
# per-card-copies design). Swapping this preload is the extension point for a real
# game-setup flow later, without touching the loading logic below.
const _DEFAULT_STARTING_DECK: StartingDeckConfig = preload("res://data/starting_deck/default_starting_deck.tres")

const _PLAYER_COLORS := [
	Color.GREEN,
	Color.YELLOW,
	Color.ORANGE,
	Color.RED,
]

var players: Array[PlayerState] = []
var current_player_index: int = 0
var round_number: int = 1

var _action_taken_this_turn: bool = false

# --- Board occupancy (canonical — Space scene nodes are a pure view of this) ---
# Keyed by the occupying Space's SpaceData resource_path (a stable, unique id since
# each Space instance references exactly one .tres). Centralizing this here — instead
# of the node-local state Space.gd used to own — is what lets a GameState snapshot
# capture "which Space has a Minion on it" for Undo, and is the extension point any
# future per-Space accumulator (e.g. a Maker-style Blood pool) should hang off of.
var space_occupancy: Dictionary = {}  # String space_id -> {"player": int, "minions": Array[CardData]}

func _ready() -> void:
	_load_all_faction_tracks()
	for i in PLAYER_COUNT:
		var p := PlayerState.new()
		p.player_name = "Player %d" % (i + 1)
		p.is_ai = i > 0
		p.player_color = _PLAYER_COLORS[i % _PLAYER_COLORS.size()]
		for count in _DEFAULT_STARTING_DECK.plans:
			for _j in count.copies:
				p.plan_draw_pile.append(count.card)
		p.plan_draw_pile.shuffle()
		for count in _DEFAULT_STARTING_DECK.minions:
			for _j in count.copies:
				p.ready_minions.append(count.card)
		players.append(p)
	# Deal opening hands.
	for p: PlayerState in players:
		draw_plans(p, HAND_SIZE)
		# TEST: seed discard with 3 random cards so the discard pile UI is exercisable.
		for _i in 3:
			var random_count = _DEFAULT_STARTING_DECK.plans[randi() % _DEFAULT_STARTING_DECK.plans.size()]
			p.plan_discard.append(random_count.card)

func _load_all_faction_tracks() -> void:
	var dir := DirAccess.open(_FACTION_TRACKS_DIR)
	if dir == null:
		push_warning("GameState: faction_tracks directory not found: %s" % _FACTION_TRACKS_DIR)
		return
	dir.list_dir_begin()
	var filename := dir.get_next()
	while filename != "":
		# Exported builds list resources as "name.tres.remap", not "name.tres" —
		# strip that suffix before checking the extension / loading.
		var real_filename := filename.trim_suffix(".remap")
		if real_filename.get_extension() in ["tres", "res"]:
			var path := _FACTION_TRACKS_DIR + real_filename
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

# --- Board occupancy queries ---

func space_id(space_data: SpaceData) -> String:
	return space_data.resource_path if space_data != null else ""

func is_space_occupied(space_data: SpaceData) -> bool:
	return space_occupancy.has(space_id(space_data))

func minions_at_space(space_data: SpaceData) -> Array[CardData]:
	var entry: Dictionary = space_occupancy.get(space_id(space_data), {})
	var minions: Array[CardData] = []
	minions.assign(entry.get("minions", []))
	return minions

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
	var placed: Array[CardData] = []
	placed.assign(minion_datas)
	space_occupancy[space_id(space_data)] = {"player": current_player_index, "minions": placed}
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
				# NOTE: can_afford() is called from Availability's per-frame-ish selectability
				# checks, so this can fire very frequently if it ever does — report_error()
				# just overwrites the single error file each time (see globals/error_tracker.gd),
				# so repeated firing isn't a growing-file problem, just some wasted I/O.
				ErrorTracker.report_error("Unsupported cost type in can_afford: %s" % GameEnums.CostType.keys()[cost_type])
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
	# Record this as a subsequent player choice on the current Action's error trace —
	# see globals/error_tracker.gd. Not part of Undo/Action Log; purely for crash forensics.
	ErrorTracker.trace_step("pending_trigger", "%s — %s" % [item.source_name(), item.action_name], {"source": item.source})
	state_changed.emit()
	return true

func _trigger_effects(effects: Array, source: Resource) -> void:
	for effect: Effect in effects:
		effect.trigger(self, source)
		if effect.is_binding():
			_current_action_binding = true

func execute_reveal() -> void:
	var p := current_player()
	var hand_plans := p.plan_hand.duplicate()
	# Move hand plans to in-play FIRST — reveal effects may key off in-play count.
	p.plan_in_play.append_array(hand_plans)
	p.plan_hand.clear()
	# Now trigger reveal effects in hand order.
	for d: CardData in hand_plans:
		_trigger_effects(d.reveal_effects, d)
	p.round_phase = PlayerState.RoundPhase.REVEALING
	_action_taken_this_turn = true
	state_changed.emit()

func execute_minion_reveal(minion_data: CardData) -> void:
	var p := current_player()
	_trigger_effects(minion_data.reveal_effects, minion_data)
	p.actions_remaining -= 1
	state_changed.emit()

func execute_recall(minion_datas: Array, space_datas: Array = []) -> void:
	var p := current_player()
	p.actions_remaining -= 1
	for d: CardData in minion_datas:
		# Only re-add to ready_minions if the card was actually still in placed_minions —
		# a trashed Minion (see trash_card()) was already erased from every zone, so its
		# space's meeple may still be selected for recall, but the card must NOT come back.
		if p.placed_minions.has(d):
			p.placed_minions.erase(d)
			p.ready_minions.append(d)
	for sd: SpaceData in space_datas:
		space_occupancy.erase(space_id(sd))
	_action_taken_this_turn = true
	state_changed.emit()

# Permanently removes card_data from the game — erased from every zone it could be in
# (not moved to any pile). Used by TrashSelf and future "Trash a Card"/"Trash a Minion"/
# "Trash a Plan" effects. A Minion trashed while placed leaves its space's meeple showing
# (no engine hook un-places it yet) — see execute_recall()'s has() guard above for why
# that's safe: recalling that space later won't resurrect the card.
func trash_card(player: PlayerState, card_data: CardData) -> void:
	player.ready_minions.erase(card_data)
	player.placed_minions.erase(card_data)
	player.plan_draw_pile.erase(card_data)
	player.plan_hand.erase(card_data)
	player.plan_in_play.erase(card_data)
	player.plan_discard.erase(card_data)
	state_changed.emit()

# --- Undo / Action Log ---
#
# Every top-level player Action (Place/Recall/Reveal/MinionReveal) is bracketed by the
# orchestrator (board.gd) with begin_undo_span()/commit_action_log(), producing one
# ActionLogEntry carrying both a full pre-action GameState snapshot (for Undo) and a
# human-readable description + replay params (params reuse the same CardData/SpaceData
# references a future multiplayer sync would ship, rather than a separate serialization
# format). Undo is snapshot/restore, not per-Effect inverse logic — see
# Effect.is_binding() for why a handful of effects (e.g. drawing a card) still refuse
# to be undone unless gentlemans_undo is on.
#
# Known gap: AdvanceWildFaction's effect opens FactionPicker and returns immediately
# (see advance_wild_faction.gd) — the player's eventual pick(s) apply outside the
# begin_undo_span()/commit_action_log() bracket of whichever action queued them, so a
# Wild-faction pick made from a Place action is not currently covered by that action's
# Undo/Action Log entry. Not solved here — flagging for whoever wires the picker into
# this system properly.
var action_log: Array[ActionLogEntry] = []
var gentlemans_undo: bool = false  # TEMP: hardcoded game-setup toggle until real Game Setup exists.

var _current_action_binding: bool = false
var _turn_log_start_index: int = 0

# Full-state snapshot: every player's mutable fields (PlayerState.snapshot()) plus the
# GameState-level globals a single Action can touch — including faction leaders (an
# Agent effect can steal another player's leader VP) and board occupancy. Arrays/
# Dictionaries are duplicated so later mutation never leaks back into a stored snapshot.
func snapshot() -> Dictionary:
	var player_snaps: Array = []
	for p: PlayerState in players:
		player_snaps.append(p.snapshot())
	var occupancy: Dictionary = {}
	for key in space_occupancy:
		var entry: Dictionary = space_occupancy[key]
		var minions: Array[CardData] = []
		minions.assign(entry.get("minions", []))
		occupancy[key] = {"player": entry.get("player", -1), "minions": minions}
	return {
		"players": player_snaps,
		"current_player_index": current_player_index,
		"round_number": round_number,
		"action_taken_this_turn": _action_taken_this_turn,
		"faction_leaders": _faction_leaders.duplicate(),
		"space_occupancy": occupancy,
	}

func restore(snap: Dictionary) -> void:
	var player_snaps: Array = snap["players"]
	for i in players.size():
		players[i].restore_from(player_snaps[i])
	current_player_index = snap["current_player_index"]
	round_number = snap["round_number"]
	_action_taken_this_turn = snap["action_taken_this_turn"]
	_faction_leaders = (snap["faction_leaders"] as Dictionary).duplicate()
	space_occupancy = (snap["space_occupancy"] as Dictionary).duplicate(true)
	state_changed.emit()

# Call immediately before executing any top-level player Action; pass the returned
# snapshot to commit_action_log() once the whole Action — including any player-ordered
# PendingAction triggers that follow it — has finished.
func begin_undo_span() -> Dictionary:
	_current_action_binding = false
	return snapshot()

func commit_action_log(pre_snapshot: Dictionary, action_type: String, description: String, params: Dictionary) -> void:
	var entry := ActionLogEntry.new()
	entry.player_index = current_player_index
	entry.round_number = round_number
	entry.description = description
	entry.action_type = action_type
	entry.params = params
	entry.binding = _current_action_binding
	entry.snapshot = pre_snapshot
	action_log.append(entry)
	_current_action_binding = false

# Undo is scoped to the current player's current turn (see _turn_log_start_index,
# reset in end_turn()) and blocked on a binding action unless gentlemans_undo is on.
func can_undo() -> bool:
	if action_log.size() <= _turn_log_start_index:
		return false
	var last: ActionLogEntry = action_log[action_log.size() - 1]
	return gentlemans_undo or not last.binding

# Pops and reverses the most recent action, restoring the exact pre-action snapshot.
# The entry is discarded entirely (not kept as an "undone" record) — per design, an
# undone action never left this local client, so it's as if it never happened.
func undo_last_action() -> bool:
	if not can_undo():
		return false
	var entry: ActionLogEntry = action_log.pop_back()
	restore(entry.snapshot)
	return true

func end_turn() -> void:
	if current_player().round_phase == PlayerState.RoundPhase.REVEALING:
		current_player().round_phase = PlayerState.RoundPhase.DONE
	_action_taken_this_turn = false
	_advance_player()
	_turn_log_start_index = action_log.size()

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
		# Fight/Influence are temporary — banked at Reveal, spent/contributed once
		# (Combat / buying Plans, neither built yet), then cleared for the new round.
		p.fight = 0
		p.influence = 0
	current_player_index = 0
	_action_taken_this_turn = false
	state_changed.emit()

# --- Fight / Influence forecast ---
#
# Fight and Influence are temporary resources: real Reveal effects bank them onto
# PlayerState.fight/influence exactly like Money/Blood/Secret, but the player needs to
# see what they're ABOUT to have before Reveal happens too. forecast_resource_gain()
# sums GainResource reveal_effects of the given type across every card currently in
# hand (ready_minions + plan_hand) — a pure read, no mutation. Callers combine this
# with the real banked amount (player.fight / player.influence) so the displayed total
# stays correct through the whole Reveal sequence: pre-Reveal it's pure forecast: once
# plan_hand empties into plan_in_play the forecast naturally drops to (at most) whatever
# Minions remain, and the real banked amount carries the rest.
# Known edge case: a Minion whose Reveal was manually triggered this round (via
# execute_minion_reveal) stays in ready_minions (Minions never change zones on Reveal),
# so its contribution can be briefly double-counted (once real, once still-forecast)
# until round end clears both. Narrow and self-correcting; not worth tracking
# per-Minion "already revealed this round" state for.
func forecast_resource_gain(player: PlayerState, gain_type: GainResource.GainType) -> int:
	var total := 0
	for d: CardData in player.ready_minions + player.plan_hand:
		for effect: Effect in d.reveal_effects:
			if effect is GainResource and (effect as GainResource).type == gain_type:
				total += (effect as GainResource).amount
	return total

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
		ErrorTracker.report_error("advance_faction_track: no track registered for '%s'" % faction_name)
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
