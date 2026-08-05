@tool
class_name StartingCardCount
extends Resource

## One entry in a StartingDeckConfig — a card and how many copies of it a player starts with.

@export var card: CardData = null
@export_range(1, 20) var copies: int = 1
