class_name SudokuCellInfo extends PuzzleCellInfo

var _mode := Utilties.SudokuMode.ICONS

# need to know the solution value
# need to allow SOLVER to "play" the game, but it's duplicated, sooo. no speical pointer? 

# need to apply the PLayer guesses
# need to show appropriate value to player
# need to tell UI if the button is disavbled
# need to tell UI to show note and notes value

signal guess_changed(button_text: String)
signal note_changed(note_text: String)

var _solution_value: int = Utilties.Sudoku_Cell_Alts.EMPTY
var _player_value: int = Utilties.Sudoku_Cell_Alts.EMPTY
var _subgrid_size : Vector2i

var _is_player_cell := false
#var _solver_value : int = Utilties.Sudoku_Cell_Alts.EMPTY
var _notes : Array[int] = []

func set_subgrid_size(size_: Vector2i) -> void: _subgrid_size = size_

func set_guess_value(value: int) -> void:
	_player_value = value
	guess_changed.emit(get_button_text())
	note_changed.emit(get_note_text())

func clear_guess() -> void:
	_player_value = Utilties.Sudoku_Cell_Alts.EMPTY
	guess_changed.emit(get_button_text())
	note_changed.emit(get_note_text())

func get_guess_value() -> int: return _player_value

# true if does not need a guess
func has_guess() -> bool: 
	if _is_player_cell: 
		return _player_value != Utilties.Sudoku_Cell_Alts.EMPTY
	return true

func set_is_player_cell(is_player_cell_: bool) -> void: 
	_is_player_cell = is_player_cell_
	note_changed.emit(get_note_text())

func is_player_cell() -> bool: return _is_player_cell

func clear_solution_value() -> void: _solution_value = Utilties.Sudoku_Cell_Alts.EMPTY

func set_solution_value(value: int) -> void: _solution_value = value

func get_solution_value() -> int: return _solution_value

func has_solution_value() -> bool: return get_solution_value() != Utilties.Sudoku_Cell_Alts.EMPTY

func is_solved() -> bool:
	if _is_player_cell:
		return _solution_value == _player_value
	return true

func clear_notes() -> void: 
	_notes.clear()
	note_changed.emit(get_note_text())

func toggle_note(value: int) -> void:
	assert(value > 0)
	if _notes.has(value):
		_notes.erase(value)
	else:
		_notes.append(value)
	note_changed.emit(get_note_text())

func get_show_notes() -> bool: return _player_value != Utilties.Sudoku_Cell_Alts.EMPTY

func get_button_value() -> int: 
	if is_player_cell():
		if _player_value == Utilties.Sudoku_Cell_Alts.EMPTY: 
			return Utilties.MineSweeper_Cells_Alts.NO_GUESS
		return _player_value
	return get_solution_value()

func get_button_text() -> String: 
	if is_player_cell():
		if _player_value == Utilties.Sudoku_Cell_Alts.EMPTY: 
			return " "
		return str(_player_value)
	return str(get_solution_value())

func get_note_text() -> String: # t(hints: Array, shape: Vector2) -> void: 
	var note_text := ""
	if has_guess():
		return note_text
	var count = 1
	for r in _subgrid_size.y:
		for c in _subgrid_size.x: 
			if _notes.has(count):
				if _mode == Utilties.SudokuMode.NUMBERS:
					note_text += str(count)
				else: 
					note_text += "*"
			else: 
				note_text += " "
			if c +1 == _subgrid_size.x:
				if r + 1 != _subgrid_size.y:
					note_text += "\n"
			else:
				note_text += " "
							
			count += 1
	return note_text
