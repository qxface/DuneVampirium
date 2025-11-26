# res://Global/signals.gd
extends Node

signal update_current_player_hand_display
# Add any other signals you need here
signal card_left_clicked(card_data: Card)
signal card_right_clicked(card_data: Card)

signal plan_zoom_show(plan_hand: CardHand)
signal plan_zoom_hide(plan_hand: CardHand)
signal plan_chosen()
signal plan_unchosen()

signal draw_pile_pressed()
signal draw_pile_right_pressed()

signal discard_pile_pressed()
signal discard_pile_right_pressed()
