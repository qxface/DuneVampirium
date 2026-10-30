class_name GainResource
extends Effect

enum GainType { MONEY, BLOOD, SECRET, FIGHT, INFLUENCE, ACTION }  # appended, not inserted — existing .tres files store ordinals

@export var type: GainType = GainType.MONEY
@export var amount: int = 1

func get_tags(source: Resource = null) -> String:
	if amount <= 0 or amount > 9:
		return ""
	return str(amount)

func get_icon(source: Resource = null) -> Texture2D:
	match type:
		GainType.MONEY:  return preload("res://assets/icons/resources/money.png")
		GainType.BLOOD:  return preload("res://assets/icons/resources/blood.png")
		GainType.SECRET: return preload("res://assets/icons/resources/secret.png")
		GainType.FIGHT:  return preload("res://assets/icons/resources/fight.png")
		GainType.INFLUENCE: return preload("res://assets/icons/resources/influence.png")
		GainType.ACTION: return preload("res://assets/icons/resources/action.png")
	return null

func trigger(game_context: Node, source: Resource = null) -> void:
	var player: PlayerState = game_context.get_current_player()
	match type:
		GainType.MONEY:  player.money  += amount
		GainType.BLOOD:  player.blood  += amount
		GainType.SECRET: player.secrets += amount
		GainType.FIGHT:  player.fight  += amount
		GainType.INFLUENCE: player.influence += amount
		# An Action token is just another resource type (CLAUDE.md 2026-10-20) — grantable by any
		# effect (Agent, Reveal, Acquire...), not special-cased to Reveal or to Minions. A token
		# gained mid-Reveal is immediately spendable on other pending Reveal choices in the same
		# phase, same as actions_remaining is read anywhere else.
		GainType.ACTION: player.actions_remaining += amount
	var resource_name: String = GainType.keys()[type].capitalize()
	var source_name: String = _source_name(source)
	print_debug("[%s] gains %d %s  ←  %s" % [player.player_name, amount, resource_name, source_name])

static func _source_name(source: Resource) -> String:
	if source == null:
		return "unknown source"
	if source is CardData:
		return (source as CardData).card_name
	if source is SpaceData:
		return (source as SpaceData).space_name
	return source.resource_path.get_file().get_basename().replace("_", " ").capitalize()
