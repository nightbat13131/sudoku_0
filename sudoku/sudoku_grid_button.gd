class_name SudokuButton extends ButtonEnhanced

enum PressMode {NA = 0, LEFT = 1, RIGHT = 2}

var _last_pressed := PressMode.NA

var _pos: Vector2

func _ready() -> void:
	super._ready()
	button_down.connect(_on_buton_down)
	set_button_mask(MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT)

func set_value(pos: Vector2, value: Variant, do_lock:= false) -> void: 
	_pos = pos
	if value == Utilties.Sudoku_Cell_Alts.EMPTY:
		value = "  "
	set_text(str(value))
	set_disabled(do_lock)

func _on_pressed() -> void: 
	if _last_pressed == PressMode.LEFT:
	#sudoku_pressed.emit(_pos)
		SudokuGame.sudoku_cell_pressed(_pos)
	elif _last_pressed == PressMode.RIGHT:
	#sudoku_pressed.emit(_pos)
		SudokuGame.sudoku_cell_clear(_pos)
	_last_pressed = PressMode.NA

func _on_buton_down() -> void: 
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_last_pressed = PressMode.LEFT
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_last_pressed = PressMode.RIGHT
	else:
		_last_pressed = PressMode.NA
