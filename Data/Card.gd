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

# Function availability booleans
var has_acquire: bool:
	get():
		return acquire_func.is_valid()
var has_action: bool:
	get():
		return action_func.is_valid()
var has_reveal: bool:
	get():
		return reveal_func.is_valid()
var has_discard: bool:
	get():
		return discard_func.is_valid()
var has_trash: bool:
	get():
		return trash_func.is_valid()

# Function references (will be set by subclasses)
var acquire_func: Callable
var action_func: Callable
var reveal_func: Callable
var discard_func: Callable
var trash_func: Callable

# Initialize the card with optional function references
func _init(
	p_acquire_func: Callable = Callable(),
	p_action_func: Callable = Callable(),
	p_reveal_func: Callable = Callable(),
	p_discard_func: Callable = Callable(),
	p_trash_func: Callable = Callable()
):
	acquire_func = p_acquire_func
	action_func = p_action_func
	reveal_func = p_reveal_func
	discard_func = p_discard_func
	trash_func = p_trash_func
	
	# Update availability booleans based on function existence
	has_acquire = acquire_func.is_valid()
	has_action = action_func.is_valid()
	has_reveal = reveal_func.is_valid()
	has_discard = discard_func.is_valid()
	has_trash = trash_func.is_valid()

func add_activation(activation: Activations, game_function: Callable) -> void:
	match activation:
		Activations.ACQUIRE:
			acquire_func = GameActions.draw_plan.bind(Ref.current_player)
		Activations.ACTION:
			action_func = GameActions.draw_plan.bind(Ref.current_player)
		Activations.REVEAL:
			reveal_func = GameActions.draw_plan.bind(Ref.current_player)
		Activations.DISCARD:
			discard_func = GameActions.draw_plan.bind(Ref.current_player)
		Activations.TRASH:
			trash_func = GameActions.draw_plan.bind(Ref.current_player)

# Function execution methods
func acquire() -> bool:
	if has_acquire:
		acquire_func.call()
		return true
	return false

func action() -> bool:
	if has_action:
		action_func.call()
		return true
	return false

func reveal() -> bool:
	if has_reveal:
		reveal_func.call()
		return true
	return false

func discard() -> bool:
	if has_discard:
		discard_func.call()
		return true
	return false

func trash() -> bool:
	if has_trash:
		trash_func.call()
		return true
	return false

# Utility methods
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
