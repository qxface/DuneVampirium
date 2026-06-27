extends Node

signal state_changed

const PLAYER_COUNT: int = 4

var players: Array[PlayerState] = []
var current_player_index: int = 0
var round_number: int = 1

var _action_taken_this_turn: bool = false

func _ready() -> void:
	for i in PLAYER_COUNT:
		var p := PlayerState.new()
		p.player_name = "Player %d" % (i + 1)
		p.is_ai = i > 0
		players.append(p)

func current_player() -> PlayerState:
	return players[current_player_index]

# --- Query ---

func can_place() -> bool:
	var p := current_player()
	return not _action_taken_this_turn and p.actions_remaining > 0 and not p.has_revealed

func can_reveal() -> bool:
	return not _action_taken_this_turn and not current_player().has_revealed

func can_end_turn() -> bool:
	return _action_taken_this_turn

# --- Actions ---

func execute_place(minion_datas: Array, plan_datas: Array) -> void:
	var p := current_player()
	p.actions_remaining -= 1
	for d: CardData in minion_datas:
		p.ready_minions.erase(d)
		p.placed_minions.append(d)
	for d: CardData in plan_datas:
		p.plan_hand.erase(d)
		p.plan_in_play.append(d)
	_action_taken_this_turn = true
	state_changed.emit()

func execute_reveal() -> void:
	current_player().has_revealed = true
	_action_taken_this_turn = true
	state_changed.emit()

func end_turn() -> void:
	_action_taken_this_turn = false
	_advance_player()

# --- Internal ---

func _advance_player() -> void:
	for i in PLAYER_COUNT:
		var idx: int = (current_player_index + 1 + i) % PLAYER_COUNT
		if not players[idx].has_revealed:
			current_player_index = idx
			state_changed.emit()
			return
	_end_round()

func _end_round() -> void:
	round_number += 1
	for p: PlayerState in players:
		p.has_revealed = false
		p.actions_remaining = p.actions_per_round
		p.plan_discard.append_array(p.plan_in_play)
		p.plan_in_play.clear()
	current_player_index = 0
	_action_taken_this_turn = false
	state_changed.emit()
