extends Panel

@export var outline_color: Color = Color(1, 0.8, 0)  # Gold outline
@export var outline_thickness: int = 3
@export var highlight_panel: Panel

var is_hovering: bool = false

func _ready():
	# Ensure mouse detection is enabled
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Connect mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# If no panel is assigned, try to find one in parent
	if highlight_panel == null:
		highlight_panel = get_parent() as Panel
		if highlight_panel == null:
			# Look for a Panel in children
			for child in get_children():
				if child is Panel:
					highlight_panel = child
					break

func _on_mouse_entered():
	is_hovering = true
	_apply_highlight()

func _on_mouse_exited():
	is_hovering = false
	_remove_highlight()

func _apply_highlight():
	if highlight_panel:
		var stylebox = StyleBoxFlat.new()
		stylebox.border_width_bottom = outline_thickness
		stylebox.border_width_top = outline_thickness
		stylebox.border_width_left = outline_thickness
		stylebox.border_width_right = outline_thickness
		stylebox.border_color = outline_color
		stylebox.bg_color = Color(0.2, 0.2, 0.2)  # Keep original background
		
		highlight_panel.add_theme_stylebox_override("panel", stylebox)

func _remove_highlight():
	if highlight_panel:
		highlight_panel.remove_theme_stylebox_override("panel")

# Public methods to manually control highlighting
func set_highlighted(highlight: bool):
	if highlight != is_hovering:
		is_hovering = highlight
		if highlight:
			_apply_highlight()
		else:
			_remove_highlight()

func is_highlighted() -> bool:
	return is_hovering
