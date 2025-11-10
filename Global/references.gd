# res://Global/references.gd
extends Node

var players: Array = []
var current_player_index: int = 0
var current_player: Player:
	get:
		if players.is_empty():
			return null
		return players[current_player_index]
func set_current_player(index: int):
	if index >= 0 and index < players.size():
		current_player_index = index
func add_player(player):
	players.append(player)
func clear_players():
	players.clear()
	current_player_index = 0

var plan_chosen: PlanHand
