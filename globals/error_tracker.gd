extends Node

# Debugging aid — NOT part of normal gameplay. Two files, each continuously overwritten
# (no history retained — see CLAUDE.md's Error Tracking section for the full design):
#
#   user://last_action_trace.json — a rolling record of the CURRENTLY in-flight
#     top-level Action: the GameState snapshot from right before it started, what the
#     Action is, and every subsequent player choice made while resolving it (which
#     PendingAction got triggered, in what order). Updated continuously so that even a
#     true engine crash — which halts execution with no chance for any GDScript code to
#     run afterward — still leaves behind "what was the game doing right before."
#
#   user://last_error_report.json — written only when report_error() is called (from an
#     existing/future push_warning()/push_error() call site that represents a genuine
#     "something is wrong" condition during play, not a startup/asset-loading issue).
#     Since a soft error doesn't halt execution, this captures the FULL live GameState at
#     the moment of the error, plus the same trace data as above for context, plus the
#     full Action Log (the list of moves that happened this session).
#
# CardData/SpaceData (and any other Resource) references inside snapshots/params are not
# JSON-serializable directly — _jsonify()/_unjsonify() replace them with their
# resource_path on the way out and load() them back on the way in.

const _TRACE_PATH := "user://last_action_trace.json"
const _ERROR_PATH := "user://last_error_report.json"

var _pre_snapshot: Dictionary = {}
var _action: Dictionary = {}
var _sub_steps: Array = []

# Call once, right at the start of a top-level Action (board.gd, alongside
# GameState.begin_undo_span() — pass the SAME snapshot so it isn't computed twice).
func start_trace(pre_snapshot: Dictionary, action_type: String, description: String, params: Dictionary) -> void:
	_pre_snapshot = pre_snapshot
	_action = {"type": action_type, "description": description, "params": params}
	_sub_steps = []
	_write_trace()

# Call after each subsequent player choice made while resolving the current Action
# (e.g. a PendingAction trigger, a FactionPicker pick).
func trace_step(kind: String, description: String, data: Dictionary = {}) -> void:
	_sub_steps.append({"kind": kind, "description": description, "data": data})
	_write_trace()

func _write_trace() -> void:
	_write_json(_TRACE_PATH, {
		"pre_action_snapshot": _pre_snapshot,
		"action": _action,
		"sub_steps": _sub_steps,
		"action_log": _serialize_action_log(),
	})

# Logs message normally (push_error, so it still shows in the console/log) AND writes a
# full crash report: the live GameState right now, the current trace for context, and
# the full Action Log (every move committed so far this session).
func report_error(message: String) -> void:
	push_error(message)
	_write_json(_ERROR_PATH, {
		"timestamp": Time.get_datetime_string_from_system(),
		"message": message,
		"current_state": GameState.snapshot(),
		"pre_action_snapshot": _pre_snapshot,
		"action": _action,
		"sub_steps": _sub_steps,
		"action_log": _serialize_action_log(),
	})

# ActionLogEntry is a RefCounted, not directly JSON-able — flatten to plain Dictionaries
# first (dropping each entry's own `snapshot`, which would balloon the file — the
# current_state/pre_action_snapshot fields already cover reconstruction; this array is
# for the human-readable "what happened" trail).
func _serialize_action_log() -> Array:
	var out: Array = []
	for entry: ActionLogEntry in GameState.action_log:
		out.append({
			"player_index": entry.player_index,
			"round_number": entry.round_number,
			"description": entry.description,
			"action_type": entry.action_type,
			"params": entry.params,
			"binding": entry.binding,
		})
	return out

func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("ErrorTracker: could not open %s for writing (error %d)" % [path, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(_jsonify(data), "\t"))
	file.close()

# Reads a dump file back into a Dictionary with Resource references restored via load().
func load_trace(path: String = _TRACE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("ErrorTracker: no file at %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("ErrorTracker: failed to parse %s as JSON" % path)
		return {}
	return _unjsonify(parsed)

# --- Resource <-> JSON ---

func _jsonify(value: Variant) -> Variant:
	if value is Resource:
		return {"__res__": (value as Resource).resource_path}
	if value is Dictionary:
		var out := {}
		for key in value:
			out[str(key)] = _jsonify(value[key])
		return out
	if value is Array:
		var out: Array = []
		for item in value:
			out.append(_jsonify(item))
		return out
	return value

func _unjsonify(value: Variant) -> Variant:
	if value is Dictionary:
		if value.size() == 1 and value.has("__res__"):
			var path: String = value["__res__"]
			return load(path) if path != "" and ResourceLoader.exists(path) else null
		var out := {}
		for key in value:
			out[key] = _unjsonify(value[key])
		return out
	if value is Array:
		var out: Array = []
		for item in value:
			out.append(_unjsonify(item))
		return out
	return value

# --- Replay ---

# Restores GameState to the pre-Action snapshot, re-executes the Action itself, then
# replays every "pending_trigger" sub-step in order — reproducing the exact sequence of
# player choices that led up to wherever the trace stopped. Other sub-step kinds (e.g. an
# "advance_wild_faction" pick, which resolves through its own async FactionPicker modal
# and logs itself as an independent trace/Action Log entry — see CLAUDE.md) aren't
# auto-replayed; they're printed so a developer can reproduce that part by hand.
func replay_trace(path: String = _TRACE_PATH) -> void:
	var trace := load_trace(path)
	if trace.is_empty():
		return

	GameState.restore(trace.get("pre_action_snapshot", {}))

	var action: Dictionary = trace.get("action", {})
	var params: Dictionary = action.get("params", {})
	var pending: Array[PendingAction] = []

	match action.get("type", ""):
		"place":
			GameState.execute_place(params.get("minions", []), params.get("plans", []), params.get("space"))
			pending = GameState.build_agent_pending_actions(params.get("minions", []), params.get("plans", []), params.get("space"))
			pending = GameState.resolve_auto_actions(pending)
		"recall":
			GameState.execute_recall(params.get("minions", []), params.get("spaces", []))
		"reveal":
			GameState.execute_reveal()
			# Reveal's pending list (Plan + Minion choices) never auto-fires — see
			# build_reveal_pending_actions() — so every trigger the player made is a
			# recorded "pending_trigger" sub-step below, same mechanism as Place's Agent
			# effects. "minion_reveal" as a standalone trace action type no longer exists
			# (superseded 2026-10-20 — Minion Reveal activations are pending-list triggers
			# within a "reveal" trace now, not their own top-level Action).
			pending = GameState.build_reveal_pending_actions()
		"advance_wild_faction":
			print_debug("ErrorTracker: 'advance_wild_faction' trace — re-trigger FactionPicker manually and pick %s for player %d" % [str(params.get("factions", [])), params.get("player_index", -1)])
		_:
			push_warning("ErrorTracker: unknown action type '%s' in trace" % action.get("type", ""))

	for step: Dictionary in trace.get("sub_steps", []):
		if step.get("kind", "") == "pending_trigger":
			var source: Resource = step.get("data", {}).get("source")
			var item := _find_pending_by_source(pending, source)
			if item != null:
				GameState.try_trigger_pending(item)
				pending.erase(item)
			else:
				push_warning("ErrorTracker: no matching pending item for step '%s' — trigger it manually" % step.get("description", ""))
		else:
			print_debug("ErrorTracker: skipped auto-replay of '%s' — reproduce manually" % step.get("description", ""))

	print_debug("ErrorTracker: replay complete (%d sub-step(s) replayed). Continue manually from here to reproduce the error." % trace.get("sub_steps", []).size())

func _find_pending_by_source(pending: Array[PendingAction], source: Resource) -> PendingAction:
	for item: PendingAction in pending:
		if item.source == source:
			return item
	return null
