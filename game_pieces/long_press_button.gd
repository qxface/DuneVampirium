class_name LongPressButton
extends Button

signal long_pressed

const HOLD_DURATION: float = 0.5

var _holding: bool = false
var _elapsed: float = 0.0
var _fill: ColorRect

func _ready() -> void:
	clip_contents = true
	_fill = ColorRect.new()
	_fill.color = Color(1.0, 1.0, 1.0, 0.25)
	_fill.size = Vector2.ZERO
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fill)
	move_child(_fill, 0)
	button_down.connect(_on_down)
	button_up.connect(_on_up)

func _process(delta: float) -> void:
	if not _holding:
		return
	_elapsed = minf(_elapsed + delta, HOLD_DURATION)
	_fill.size = Vector2(size.x * (_elapsed / HOLD_DURATION), size.y)
	if _elapsed >= HOLD_DURATION:
		_reset()
		long_pressed.emit()

func _on_down() -> void:
	_holding = true
	_elapsed = 0.0

func _on_up() -> void:
	_reset()

func _reset() -> void:
	_holding = false
	_elapsed = 0.0
	if _fill:
		_fill.size = Vector2.ZERO
