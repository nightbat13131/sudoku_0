class_name SudokuButton extends ButtonEnhanced

#signal sudoku_pressed(pos: Vector2i)

var _pos: Vector2

func set_value(pos: Vector2, value: Variant, do_lock:= false) -> void: 
	_pos = pos
	set_text(str(value))
	set_disabled(do_lock)

func _on_pressed() -> void: 
	#sudoku_pressed.emit(_pos)
	SudokuGame.sudoku_pressed(_pos)
