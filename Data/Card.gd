# res://Data/Card.gd
class_name Card
extends Resource

enum CardType {PLAN, MINION}
enum OriginType { VAMPIRE, SUPERNATURAL, HUMAN, NONE }
enum Activations {ACQUIRE, ACTION, REVEAL, DISCARD, TRASH}

@export var card_type: CardType = CardType.PLAN
@export var card_name: String = ""
@export var card_description: String = ""

# Clan booleans
@export var is_primori: bool = false
@export var is_volupta: bool = false
@export var is_vorace: bool = false

# Action booleans
@export var is_intrigue: bool = false
@export var is_hunting: bool = false
@export var is_battle: bool = false

# Origin type
@export var origin: OriginType = OriginType.VAMPIRE

# New activation system
@export var acquire_activation: Activation
@export var action_activation: Activation
@export var reveal_activation: Activation
@export var discard_activation: Activation
@export var trash_activation: Activation

# Function availability booleans (compatibility with old system)
var has_acquire: bool:
	get():
		return acquire_activation and not acquire_activation.is_empty()
var has_action: bool:
	get():
		return action_activation and not action_activation.is_empty()
var has_reveal: bool:
	get():
		return reveal_activation and not reveal_activation.is_empty()
var has_discard: bool:
	get():
		return discard_activation and not discard_activation.is_empty()
var has_trash: bool:
	get():
		return trash_activation and not trash_activation.is_empty()

# Initialize the card with activation objects
func _init():
	# Initialize empty activations
	acquire_activation = Activation.EMPTY
	action_activation = Activation.EMPTY
	reveal_activation = Activation.EMPTY
	discard_activation = Activation.EMPTY
	trash_activation = Activation.EMPTY

# Add activation using the new system
func add_activation(activation_type: Activations, requirement: Requirement = null, cost: Cost = null, reward: Reward = null) -> void:
	var new_activation = Activation.new(requirement, cost, reward)

	match activation_type:
		Activations.ACQUIRE:
			acquire_activation = new_activation
		Activations.ACTION:
			action_activation = new_activation
		Activations.REVEAL:
			reveal_activation = new_activation
		Activations.DISCARD:
			discard_activation = new_activation
		Activations.TRASH:
			trash_activation = new_activation

# Function execution methods (compatibility with old system)
func acquire(player: Player) -> bool:
	if has_acquire:
		return acquire_activation.execute(player)
	return false

func action(player: Player) -> bool:
	if has_action:
		return action_activation.execute(player)
	return false

func reveal(player: Player) -> bool:
	if has_reveal:
		return reveal_activation.execute(player)
	return false

func discard(player: Player) -> bool:
	if has_discard:
		return discard_activation.execute(player)
	return false

func trash(player: Player) -> bool:
	if has_trash:
		return trash_activation.execute(player)
	return false

# Utility methods (unchanged)
func get_clans() -> Array[String]:
	var clans: Array[String] = []
	if is_primori: clans.append("Primori")
	if is_volupta: clans.append("Volupta")
	if is_vorace: clans.append("Vorace")
	return clans

func get_actions() -> Array[String]:
	var actions: Array[String] = []
	if is_intrigue: actions.append("Intrigue")
	if is_hunting: actions.append("Hunting")
	if is_battle: actions.append("Battle")
	return actions

func get_origin_name() -> String:
	match origin:
		OriginType.VAMPIRE: return "Vampire"
		OriginType.SUPERNATURAL: return "Supernatural"
		OriginType.HUMAN: return "Human"
		_: return "Unknown"
