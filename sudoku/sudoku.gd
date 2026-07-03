class_name Sudoku extends _SudokuPuzzle
## https://www.youtube.com/watch?v=ZTDTRz-TV3U&list=PL19FbkLnqUDiT9-aBYiauxviYSxh9FQDx

func get_domain_max() -> int: return _initial_domain.max()

func get_subgrid_count() -> int: return (_grid_size.x % _subgrid_size.x) * (_grid_size.y % _subgrid_size.y)

func request_player_guess(pos: Vector2i, num: int) -> void:
	assert(num != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	var cell : SudokuCellInfo = get_cell_from_pos(pos)
	assert(cell.is_player_cell())
	var prevoius_num : int = cell.get_guess_value()
	_undo_redo.create_action(Utilties.SODOKU_GUESS)
	
	if prevoius_num == num:
		_undo_redo.add_do_method(cell.clear_guess)
		_undo_redo.add_undo_method(cell.set_guess_value.bind(prevoius_num))
	else: 
		_undo_redo.add_do_method(cell.set_guess_value.bind(num))
		_undo_redo.add_undo_method(cell.set_guess_value.bind(prevoius_num))
	_undo_redo.commit_action()
	_win_check()

func request_player_hint(pos: Vector2i, num: int) -> void:
	assert(num != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	var cell : SudokuCellInfo = get_cell_from_pos(pos)
	assert(cell.is_player_cell())
	if num == Utilties.Sudoku_Cell_Alts.EMPTY:
		return ## no guess being made
	_undo_redo.create_action(Utilties.SUDOKU_HINT)
	_undo_redo.add_do_method(cell.toggle_note.bind(num) )
	_undo_redo.add_undo_method(cell.toggle_note.bind(num) )
	_undo_redo.commit_action()

func _win_check() -> void:
	var result := _get_results()
	## writen knowing more result types may be added to the emum in the future
	if result == Utilties.Results.WIN: # [Utilties.Results.WIN, Utilties.Results.LOSS].has(result):
		_undo_redo.clear_history()
		puzzle_complete.emit(result)
		for row in _cells_grid:
			for cell : SudokuCellInfo in row:
				cell.game_over()
