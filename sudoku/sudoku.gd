class_name Sudoku extends _SudokuPuzzle
## https://www.youtube.com/watch?v=ZTDTRz-TV3U&list=PL19FbkLnqUDiT9-aBYiauxviYSxh9FQDx

signal hint_changed(pos: Vector2i, hint: Array, shape: Vector2i)

var _hints : Dictionary[Vector2i, Array]
func get_player_grid() -> Array[Array] : return _player_grid

func get_domain_max() -> int: return _initial_domain.max()

func get_subgrid_count() -> int: return (_grid_size.x % _subgrid_size.x) * (_grid_size.y % _subgrid_size.y)

func request_player_guess(pos: Vector2i, num: int) -> void:
	assert(num != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	var prevoius_num : int = _guess_grid[pos.y][pos.x]
	if prevoius_num == Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED:
		push_warning("Invalid spot guessed at", pos)
		return
	elif _guess_grid[pos.y][pos.x] == num:
		num = Utilties.Sudoku_Cell_Alts.EMPTY as int
	_undo_redo.create_action(Utilties.SODOKU_GUESS)
	_undo_redo.add_do_method(__set_guess_value_ur.bind(pos, num) )
	_undo_redo.add_undo_method(__set_guess_value_ur.bind(pos, prevoius_num) )
	_undo_redo.commit_action()

func request_player_hint(pos: Vector2i, num: int) -> void:
	assert(num != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	if _guess_grid[pos.y][pos.x] == Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED:
		push_warning("Invalid spot hinted at", pos)
		return
	elif num == Utilties.Sudoku_Cell_Alts.EMPTY:
		pass
		return ## no guess being made
	elif _guess_grid[pos.y][pos.x] != Utilties.Sudoku_Cell_Alts.EMPTY:
		return # no change needed
	var prevoius_hint : Array = _hints.get(pos, [])
	var new_hint : Array = prevoius_hint.duplicate()
	if prevoius_hint.has(num): 
		new_hint.erase(num)
	else: 
		new_hint.append(num)
	_undo_redo.create_action(Utilties.SUDOKU_HINT)
	_undo_redo.add_do_method(__set_hint_value_ur.bind(pos, new_hint) )
	_undo_redo.add_undo_method(__set_hint_value_ur.bind(pos, prevoius_hint) )
	_undo_redo.commit_action()

## function for UndoRedo to call
func __set_guess_value_ur(pos: Vector2i, num: int) -> void:
	assert(num != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	assert(_guess_grid[pos.y][pos.x] != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	_guess_grid[pos.y][pos.x] = num
	cell_changed.emit(pos, num)
	if _get_results() == Utilties.Results.WIN:
		print("puzzle solved")
		_undo_redo.clear_history()

## function for UndoRedo to call
func __set_hint_value_ur(pos: Vector2i, hint: Array) -> void:
	if hint.is_empty():
		_hints.erase(pos)
	else: 
		_hints[pos] = hint
	hint_changed.emit(pos, hint, _subgrid_size)
