# res://UI/mouse_handler_component.gd
class_name MouseHandler
extends Panel
signal mouse_left_click
signal mouse_right_click
signal mouse_hover_enter
signal mouse_hover_exit
@export var Normal: StyleBoxFlat = preload("res://UI/StyleBox/card_normal.tres")
@export var Hover: StyleBoxFlat = preload("res://UI/StyleBox/card_highlight.tres")
@export var Selected: StyleBoxFlat

var is_hovering: bool = false

func _ready():
	# Ensure mouse detection is enabled
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Check if parent has required click handler functions
	_setup_parent_connections()
	
	# Connect mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	
	# Set up existing children to pass mouse events
	_setup_existing_children()
	
	# Connect to watch for new children being added
	child_entered_tree.connect(_on_child_entered_tree)
	
	_remove_highlight()

func _setup_parent_connections():
	var parent = get_parent()
	if parent == null:
		push_error("MouseHandlerComponent: No parent found!")
		return
	
	# Connect our signals to parent methods if they exist
	if parent.has_method("_on_mouse_left_click"):
		mouse_left_click.connect(parent._on_mouse_left_click)
	else:
		push_warning("MouseHandlerComponent: Parent missing method '_on_mouse_left_click()'")
	
	if parent.has_method("_on_mouse_right_click"):
		mouse_right_click.connect(parent._on_mouse_right_click)
	else:
		push_warning("MouseHandlerComponent: Parent missing method '_on_mouse_right_click()'")
	
	if parent.has_method("_on_mouse_hover_enter"):
		mouse_hover_enter.connect(parent._on_mouse_hover_enter)
	else:
		push_warning("MouseHandlerComponent: Parent missing method '_on_mouse_hover_enter()'")
	
	if parent.has_method("_on_mouse_hover_exit"):
		mouse_hover_exit.connect(parent._on_mouse_hover_exit)
	else:
		push_warning("MouseHandlerComponent: Parent missing method '_on_mouse_hover_exit()'")

func _setup_existing_children():
	# Recursively set all child controls to pass mouse events
	_set_children_mouse_filter_recursive(get_parent())

func _set_children_mouse_filter_recursive(node: Node):
	for child in node.get_children():
		if child is MouseHandler:
			child.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			if child is Control:
				child.mouse_filter = Control.MOUSE_FILTER_PASS
			_set_children_mouse_filter_recursive(child)

func _on_child_entered_tree(node: Node):
	# When a new child is added, set its mouse filter and watch its children
	_set_children_mouse_filter_recursive(get_parent())
	
	# Also connect to watch for grandchildren being added
	if node is Node:
		node.child_entered_tree.connect(_on_child_entered_tree)

func _on_mouse_entered():
	is_hovering = true
	mouse_hover_enter.emit()
	#_apply_highlight()

func _on_mouse_exited():
	is_hovering = false
	mouse_hover_exit.emit()
	#_remove_highlight()

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			mouse_left_click.emit()
			if is_inside_tree():
				get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			mouse_right_click.emit()
			if is_inside_tree():
				get_viewport().set_input_as_handled()

func _apply_highlight():
	add_theme_stylebox_override("panel", Hover)
	
func _remove_highlight():
	add_theme_stylebox_override("panel", Normal)

# Public methods
func set_highlighted(highlight: bool):
	if highlight != is_hovering:
		is_hovering = highlight
		if highlight:
			_apply_highlight()
		else:
			_remove_highlight()

func is_highlighted() -> bool:
	return is_hovering
