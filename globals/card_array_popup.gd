extends CanvasLayer

const MINION_SCENE := preload("res://game_pieces/minion.tscn")
const PLAN_SCENE   := preload("res://game_pieces/plan.tscn")

var _overlay: ColorRect
var _panel: Panel
var _title_label: Label
var _scroll: ScrollContainer
var _card_hbox: HBoxContainer
var _close_button: Button

func _ready() -> void:
	layer = 10
	visible = false
	_build_ui()

func _build_ui() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.72)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.gui_input.connect(_on_overlay_input)
	add_child(_overlay)

	_panel = Panel.new()
	_panel.anchor_left   = 0.05
	_panel.anchor_top    = 0.1
	_panel.anchor_right  = 0.95
	_panel.anchor_bottom = 0.9
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	vbox.offset_left   = 24.0
	vbox.offset_top    = 16.0
	vbox.offset_right  = -24.0
	vbox.offset_bottom = -16.0
	_panel.add_child(vbox)

	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 36)
	vbox.add_child(_title_label)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(_scroll)

	_card_hbox = HBoxContainer.new()
	_card_hbox.add_theme_constant_override("separation", 8)
	_scroll.add_child(_card_hbox)

	_close_button = Button.new()
	_close_button.text = "Close"
	_close_button.add_theme_font_size_override("font_size", 30)
	_close_button.custom_minimum_size = Vector2(0, 60)
	_close_button.pressed.connect(close)
	vbox.add_child(_close_button)

func show_cards(card_datas: Array, title: String = "") -> void:
	for child in _card_hbox.get_children():
		child.queue_free()

	_title_label.text = title
	_title_label.visible = not title.is_empty()

	for data: CardData in card_datas:
		var scene := MINION_SCENE if data.card_type == CardData.CardType.MINION else PLAN_SCENE
		var node: Card = scene.instantiate()
		node.can_select = false
		_card_hbox.add_child(node)
		node.card_data = data  # set after add_child so @onready vars are valid

	visible = true

func close() -> void:
	visible = false
	for child in _card_hbox.get_children():
		child.queue_free()

func _on_overlay_input(event: InputEvent) -> void:
	# Swallow all input so clicks on the dark overlay don't reach the board.
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event is InputEventKey:
		var ke := event as InputEventKey
		if ke.pressed and ke.keycode == KEY_ESCAPE:
			close()
			get_viewport().set_input_as_handled()
