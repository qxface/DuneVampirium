# res://BoardParts/ZoomArea/plan_zoom.gd
# res://BoardParts/PlayerHand/plan_zoom.gd
class_name PlanZoom
extends PlanBase

var chosen_card_data: Card

@onready var acquire_icons: ActivationIcons = %AcquireIcons
@onready var action_icons: ActivationIcons = %ActionIcons
@onready var reveal_icons: ActivationIcons = %RevealIcons
@onready var discard_icons: ActivationIcons = %DiscardIcons
@onready var trash_icons: ActivationIcons = %TrashIcons

func _ready():
	super()
	
	icons.custom_minimum_size.y = 100
	
	#zoom_icon(primori_icon)
	#zoom_icon(volupta_icon)
	#zoom_icon(vorace_icon)
	#
	#zoom_icon(intrigue_icon)
	#zoom_icon(hunting_icon)
	#zoom_icon(battle_icon)
	#
	#zoom_icon(origin_icon)
	
	Signals.plan_chosen.connect(_on_plan_chosen)
	Signals.plan_unchosen.connect(_on_plan_unchosen)
	Signals.plan_zoom_show.connect(_on_plan_zoom_show)
	Signals.plan_zoom_hide.connect(_on_plan_zoom_hide)

func _on_mouse_left_click():
	print("Left Clicked Plan Zoom.")

func _on_mouse_right_click():
	print("Right Clicked Plan Zoom.")

func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	pass

func _on_plan_zoom_show(new_plan_hand: PlanHand) -> void:
	set_card_data(new_plan_hand.card_data)
	visible = true

func _on_plan_zoom_hide(new_plan_hand: PlanHand) -> void:
	if !chosen_card_data:
		visible = false
	else:
		set_card_data(chosen_card_data)

func _on_plan_chosen() -> void:
	chosen_card_data = Ref.plan_chosen.card_data
	
func _on_plan_unchosen() -> void:
	chosen_card_data = null
#
#func zoom_icon(icon: TextureRect):
	## Get the current texture path
	#var current_texture = icon.texture
	#if current_texture == null:
		#return
	#
	## Get the resource path of the current texture
	#var texture_path = current_texture.resource_path
	#if texture_path == "":
		#return
	#
	## Extract file information
	#var file_path = texture_path.get_base_dir()
	#var file_name = texture_path.get_file()
	#var file_extension = texture_path.get_extension()
	#var base_name = file_name.trim_suffix("." + file_extension)
	#
	## Construct the large version filename
	#var large_filename = base_name + "_large." + file_extension
	#var large_texture_path = file_path.path_join(large_filename)
	#
	## Check if the large texture exists and load it
	#if FileAccess.file_exists(large_texture_path):
		#var large_texture = load(large_texture_path)
		#if large_texture:
			#icon.texture = large_texture
