# https://github.com/alicommit-malp/sudoku/blob/main/README.md
# MIT licence 
# https://github.com/alicommit-malp/sudoku/blob/main/puzzle_generator.py

class_name _SudokuPuzzle extends PuzzleFoundation

@export var _grid_size: Vector2i #: get = get_grid_size , set = _set_grid_size
@export var _subgrid_size : Vector2i # : set = _set_subgrid_size
@warning_ignore("unused_private_class_variable")
@export var _difficulty := Utilties.Difficulty.EASY
var _initial_domain : Array # Range does not return a type array
var _player_grid : Array[Array]
var _solution_grid : Array[Array]
var _guess_grid : Array[Array]

## Puzzle specific Generation
func _new_puzzle() -> void:
	assert(0 == _grid_size.x % _subgrid_size.x)
	assert(0 == _grid_size.y % _subgrid_size.y)
	_initial_domain = range(1,max(_grid_size.x, _grid_size.y)+1)
	_generate_professional_sudoku(_get_difficulty_count(_difficulty), [true, false].pick_random())

func get_grid_size() -> Vector2i: return _grid_size

func get_subgrid_size() -> Vector2: return _subgrid_size

func _generate_professional_sudoku(min_clues := 30, symmetry := false) -> void:
	_player_grid.clear()
	_solution_grid.clear()
	_guess_grid.clear()
	for y: int in range(_grid_size.y):
		_solution_grid.append([])
		_guess_grid.append([])
		for x: int in range(_grid_size.x):
			_solution_grid[y].append(Utilties.Sudoku_Cell_Alts.EMPTY)
			_guess_grid[y].append(Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	_fill_solution()
	_player_grid = _solution_grid.duplicate(true)

	if symmetry:
		_remove_numbers_with_symmetry(min_clues)
		pass
	else:
		_remove_numbers_exact_clues(min_clues)

		# Note: we do not force the puzzle to *exactly* `min_clues`. Forcing it
		# would require either restoring givens (no harm) or removing more cells
		# without a uniqueness check (which silently produces ambiguous puzzles).
		# `min_clues` is treated as a target lower bound; the achieved count may
		# be higher when uniqueness-preserving removal cannot continue. Symmetric
		# removal in particular often settles well above the target.

func _solve(grid, count, cap) -> void:
	if count[0] >= cap:
		return
	for irow in range(_grid_size.y):
		for jcol in range(_grid_size.x):
			if grid[irow][jcol] == 0:
				for num in _initial_domain:
					if _is_valid(grid, irow, jcol, num):
						grid[irow][jcol] = num
						self._solve(grid, count, cap)
						grid[irow][jcol] = 0
						if count[0] >= cap:
							return
				return
	count[0] += 1

## Recursive backtracking to fill the grid
func _fill_solution() -> bool:
	var num_list : Array
	for row: int in range(_grid_size.y):
		for col: int in range(_grid_size.x):
			if _solution_grid[row][col] == Utilties.Sudoku_Cell_Alts.EMPTY:
				num_list = _initial_domain.duplicate()
				num_list.shuffle()
				for num: int in num_list:
					if _is_valid(_solution_grid, row, col, num):
						_solution_grid[row][col] = num
						if _fill_solution():
							return true
						_solution_grid[row][col] = Utilties.Sudoku_Cell_Alts.EMPTY
				return false
	return true

## Remove numbers to leave exactly num_clues in the grid
func _remove_numbers_exact_clues(num_clues) -> void:
	var cells_to_remove: int = _grid_size.x * _grid_size.y - num_clues  # We want to remove this many cells
	var removed := 0
	var all_cells : Array[Vector2i]
	var backup: int
	for _r in range(_grid_size.y):
		for _c in range(_grid_size.x):
			all_cells.append(Vector2i(_c, _r))
	all_cells.shuffle()
	for pos in all_cells:
		if removed >= cells_to_remove:
			break
		backup = _player_grid[pos.y][pos.x]
		if backup == Utilties.Sudoku_Cell_Alts.EMPTY:
			continue
		_player_grid[pos.y][pos.x] = Utilties.Sudoku_Cell_Alts.EMPTY

		# Check if the puzzle still has a unique solution
		if _has_unique_solution(_player_grid):
			_guess_grid[pos.y][pos.x] = Utilties.Sudoku_Cell_Alts.EMPTY
			removed += 1  # Successful removal
		else:
			_player_grid[pos.y][pos.x] = backup  # Restore if removing breaks uniqueness

## Populate in blanks symetrically
func _remove_numbers_with_symmetry(num_clues: int) -> void:
	var cells_to_remove: int = (_grid_size.x * _grid_size.y) - num_clues
	var removed := 0

		# Representatives of each 180°-rotational pair. The center cell (4, 4)
		# is its own pair and must be counted as a single cell, not two.
	var symmetric_pairs = []
	var max_r = _grid_size.y - 1
	var max_c = _grid_size.x - 1
	for r in range(_grid_size.y):
		for c in range(_grid_size.x):
			if r <= (max_r - r) and c <= (max_c - c):
				symmetric_pairs.append([r, c, max_r - r, max_c - c])
	symmetric_pairs.shuffle()

	var backup1 : int
	var backup2 : int
	for rcr_c_ in symmetric_pairs:
		var r1 = rcr_c_[0]
		var c1 = rcr_c_[1]
		var r2 = rcr_c_[2]
		var c2 = rcr_c_[3]
		#for r1, c1, r2, c2 in symmetric_pairs:
		if removed >= cells_to_remove:
			break
		backup1 = _player_grid[r1][c1]
		backup2 = _player_grid[r2][c2]
		if backup1 == Utilties.Sudoku_Cell_Alts.EMPTY or backup2 == Utilties.Sudoku_Cell_Alts.EMPTY:
			continue # skip rest of THIS loop
		_player_grid[r1][c1] = Utilties.Sudoku_Cell_Alts.EMPTY
		_player_grid[r2][c2] = Utilties.Sudoku_Cell_Alts.EMPTY
		if _has_unique_solution(_player_grid):
			_guess_grid[r1][c1] = Utilties.Sudoku_Cell_Alts.EMPTY
			_guess_grid[r2][c2] = Utilties.Sudoku_Cell_Alts.EMPTY
			if [[r1],[c1]] == [[r2],[c2]]:
				removed += 1
			else:
				removed += 2
		else:
			_player_grid[r1][c1] = backup1
			_player_grid[r2][c2] = backup2

func _has_unique_solution(grid) -> bool: return _count_solutions(grid) == 1

func is_guess_complete() -> bool:
	for row: Array[int] in _guess_grid:
		for col: int in row:
			if col == Utilties.Sudoku_Cell_Alts.EMPTY:
				return false
	return true

## Currently built assiming the "only 1 solution" algo is working. 
func is_solved() -> bool: 
	var guess: int
	for row: int in _grid_size.y:
		for col: int in _grid_size.x:
			guess = _guess_grid[row][col]
			if guess != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED:
				if guess != _solution_grid[row][col]:
					return false
	return true

## "is this unique" helper
func _count_solutions(grid, cap=2) -> int:
	var count = [0]
	_solve(grid.duplicate(true), count, cap)
	return count[0]

## Helper to check whether a number can be placed in a given cell
func _is_valid(board, row, col, num) -> bool:
	for _col: int in range(board[0].size()):
		if _col != col:
			if board[row][_col] == num:
				return false
	for _row: int in range(board.size()):
		if _row != row:
			if board[_row][col] == num:
				return false
	var box_row_start: int = row - row % _subgrid_size.y
	var box_col_start: int = col - col % _subgrid_size.x
	for __row in range(_subgrid_size.y):
		for __col in range(_subgrid_size.x):
			if board[__row + box_row_start][__col + box_col_start] == num:
				return false
	return true

## Select the difficulty level and return the number of blanks.
func _get_difficulty_count(difficulty: Utilties.Difficulty) -> int:
	var cell_count : int = _grid_size.x * _grid_size.y
	match difficulty:
		Utilties.Difficulty.EASY:
			@warning_ignore("integer_division")
			return ceili(cell_count * .45) # 40
		Utilties.Difficulty.MEDIUM:
			@warning_ignore("integer_division")
			return ceili(cell_count * .35) # 35
		_: 
			@warning_ignore("integer_division")
			return ceili(cell_count * .30) # 30
