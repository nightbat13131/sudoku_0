class_name Sudoku extends _SudokuPuzzle
## https://www.youtube.com/watch?v=ZTDTRz-TV3U&list=PL19FbkLnqUDiT9-aBYiauxviYSxh9FQDx

signal puzzle_generated
signal cell_changed(pos: Vector2i, num: int)

var _undo_redo : UndoRedo

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
		return # no change needed
	_undo_redo.create_action(Utilties.SODOKU_GUESS)
	_undo_redo.add_do_method(__set_guess_value_ur.bind(pos, num) )
	_undo_redo.add_undo_method(__set_guess_value_ur.bind(pos, prevoius_num) )
	_undo_redo.commit_action()

func generate_next_puzzle() -> bool: 
	if _undo_redo:
		_undo_redo.clear_history()
	else: 
		_undo_redo = UndoRedo.new()
	_new_game(_grid_size, _subgrid_size, _difficulty)
	puzzle_generated.emit()
	return true

## Display the Sudoku grid with row and column numbers.
func display_grid(grid : Array[Array], title="Sudoku Grid"):
	print(title)
	var row : Array
	var row_print := ""
	var cell : int
	for y in range(grid.size()):
		row = grid[y]
		row_print = str(y) + "| "
		for j in range(row.size()):
		#for j, cell in enumerate(row):
			cell = row[j]
			if cell > 0:
				row_print += str(cell)
			else: 
				row_print += "."
			row_print += " | "
		print(row_print)

## function for UndoRedo to call
func __set_guess_value_ur(pos: Vector2i, num: int) -> void:
	assert(num != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	assert(_guess_grid[pos.y][pos.x] != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	_guess_grid[pos.y][pos.x] = num
	cell_changed.emit(pos, num)
	if is_guess_complete():
		print("guess complete")
		if is_guess_correct():
			print("puzzle solved")

func request_undo() -> void: _undo_redo.undo()

func request_redo() -> void: _undo_redo.redo()
