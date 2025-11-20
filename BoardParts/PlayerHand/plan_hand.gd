# res://BoardParts/PlayerHand/plan_hand.gd
class_name PlanHand
extends PlanBase

var is_hovered: bool = false:
	set(value):
		is_hovered = value
		_set_border()
var is_chosen: bool = false:
	set(value):
		is_chosen = value
		_set_border()

func _ready() -> void:
	super()
	Signals.plan_chosen.connect(_on_plan_chosen)
	Signals.plan_unchosen.connect(_on_plan_unchosen)
	_minimize_icons()

func _on_mouse_entered() -> void:
	is_hovered = true
	Signals.plan_zoom_show.emit(self)
	_set_border()

func _on_mouse_exited() -> void:
	is_hovered = false
	Signals.plan_zoom_hide.emit(self)
	_set_border()

func _on_mouse_left_click() -> void:
	if Ref.plan_chosen == self:
		Ref.plan_chosen = null
		Signals.plan_unchosen.emit()
	else:
		Ref.plan_chosen = self
		Signals.plan_chosen.emit()

func _on_mouse_right_click() -> void:
	print("PlanHandCard: Right click detected via signal!")
	assert(card_data, "No card_data loaded when discarding.")

	print("Attempting to discard card: ", card_data.card_name)
	if Ref.current_player:
		var success := GameActions.discard_plan(Ref.current_player, card_data)
		if success:
			print("Card discarded successfully")
			if get_parent():
				get_parent().remove_child(self)
			queue_free()
			Signals.update_current_player_hand_display.emit()
		else:
			print("Failed to discard card")

func _on_mouse_hover_enter():
	is_hovered = true
	#_apply_hover_effect()

func _on_mouse_hover_exit():
	is_hovered = false
	#_apply_normal_effect()

func _on_plan_chosen() -> void:
	if Ref.plan_chosen == self:
		is_chosen = true
	else:
		is_chosen = false
	_set_border()
	#_apply_normal_effect() 

func _on_plan_unchosen() -> void:
	is_chosen = false
	_set_border()
	#_apply_normal_effect() 

#func _apply_hover_effect() -> void:
	#if is_chosen:
		#add_theme_stylebox_override("panel", CARD_CHOSEN)
	#else:
		#add_theme_stylebox_override("panel", CARD_HOVER)
#
#func _apply_normal_effect() -> void:
	#if is_chosen:
		#add_theme_stylebox_override("panel", CARD_CHOSEN)
	#else:
		#add_theme_stylebox_override("panel", CARD_NORMAL)
#
#func _apply_click_effect() -> void:
	## Brief visual feedback for click
	#var tween = create_tween()
	#tween.tween_property(self, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.08)
	#tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.08)

func _set_border() -> void:
	if is_chosen:
		add_theme_stylebox_override("panel", CARD_CHOSEN)
	elif is_hovered:
		add_theme_stylebox_override("panel", CARD_HOVER)
	else:
		add_theme_stylebox_override("panel", CARD_NORMAL)

func _minimize_icons() -> void:
	acquire_icons.visible = false
	action_icons.visible = false
	reveal_icons.visible = false
	discard_icons.visible = false
	trash_icons.visible = false
	
	primori_bg.color = primori_icon.self_modulate
	volupta_bg.color = volupta_icon.self_modulate
	vorace_bg.color = vorace_icon.self_modulate
	primori_icon.visible = false
	volupta_icon.visible = false
	vorace_icon.visible = false
	
	intrigue_bg.color = intrigue_icon.self_modulate
	hunting_bg.color = hunting_icon.self_modulate
	battle_bg.color = battle_icon.self_modulate
	intrigue_icon.visible = false
	hunting_icon.visible = false
	battle_icon.visible = false
