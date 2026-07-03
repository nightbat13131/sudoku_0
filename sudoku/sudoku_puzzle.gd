# https://github.com/alicommit-malp/sudoku/blob/main/README.md
# MIT licence 
# https://github.com/alicommit-malp/sudoku/blob/main/puzzle_generator.py

class_name _SudokuPuzzle extends PuzzleFoundation

@export var _grid_size: Vector2i #: get = get_grid_size , set = _set_grid_size
@export var _subgrid_size : Vector2i # : set = _set_subgrid_size
@warning_ignore("unused_private_class_variable")
@export var _difficulty := Utilties.Difficulty.EASY
var _initial_domain : Array # Range does not return a type array
#var _guess_grid : Array[Array]

## Puzzle specific Generation
func _new_puzzle() -> void:
	assert(0 == _grid_size.x % _subgrid_size.x)
	assert(0 == _grid_size.y % _subgrid_size.y)
	_initial_domain = range(1,max(_grid_size.x, _grid_size.y)+1)
	_generate_professional_sudoku(_get_difficulty_count(_difficulty), [true, false].pick_random())

func _restart() -> void:
	for row in get_cells_grid():
		for cell: SudokuCellInfo in row:
			cell.clear_guess()
			cell.clear_notes()

func get_grid_size() -> Vector2i: return _grid_size

func get_subgrid_size() -> Vector2: return _subgrid_size

func _generate_professional_sudoku(min_clues := 30, symmetry := false) -> void:
	_cells_grid.clear()
	var cell : SudokuCellInfo
	for y: int in range(_grid_size.y):
		_cells_grid.append([])
		for x: int in range(_grid_size.x):
			cell = SudokuCellInfo.new()
			cell.set_position(Vector2i(x, y))
			cell.set_subgrid_size(get_subgrid_size())
			_cells_grid[y].append(cell)
	_fill_solution()
	#_player_grid = _solution_grid.duplicate(true)

	if symmetry:
		_remove_numbers_with_symmetry(min_clues)
	else:
		_remove_numbers_exact_clues(min_clues)

		# Note: we do not force the puzzle to *exactly* `min_clues`. Forcing it
		# would require either restoring givens (no harm) or removing more cells
		# without a uniqueness check (which silently produces ambiguous puzzles).
		# `min_clues` is treated as a target lower bound; the achieved count may
		# be higher when uniqueness-preserving removal cannot continue. Symmetric
		# removal in particular often settles well above the target.


## Recursive backtracking to fill the grid
func _fill_solution() -> bool:
	var num_list : Array
	for row: Array in _cells_grid:
		for cell: SudokuCellInfo in row:
			if !cell.has_solution_value(): # _solution_grid[row][col] == Utilties.Sudoku_Cell_Alts.EMPTY:
				num_list = _initial_domain.duplicate()
				num_list.shuffle()
				for num: int in num_list:
					#if _is_valid(_solution_grid, row, col, num):
					if _is_valid(cell, num):
						cell.set_solution_value(num) # _solution_grid[row][col] = num
						if _fill_solution():
							return true
						cell.clear_solution_value() # _solution_grid[row][col] = Utilties.Sudoku_Cell_Alts.EMPTY
				return false
	return true

## Remove numbers to leave exactly num_clues in the grid
func _remove_numbers_exact_clues(num_clues) -> void:
	var cells_to_remove: int = _grid_size.x * _grid_size.y - num_clues  # We want to remove this many cells
	#var focus_cell : SudokuCellInfo
	var removed := 0
	var all_cells : Array[SudokuCellInfo] # Array[Vector2i]
	#var backup: int
	for row : Array in _cells_grid:
	#for _r in range(_grid_size.y):
		for cell : SudokuCellInfo in row: 
		#for _c in range(_grid_size.x):
			#all_cells.append(Vector2i(_c, _r))
			all_cells.append(cell)
	all_cells.shuffle()
	
	for cell in all_cells:
		if removed >= cells_to_remove:
			break
		#focus_cell = _cells_grid[pos.y][pos.x]
		#backup = _player_grid[pos.y][pos.x]
		if cell.is_player_cell(): # backup == Utilties.Sudoku_Cell_Alts.EMPTY:
			continue
		cell.set_is_player_cell(true)
		#_player_grid[pos.y][pos.x] = Utilties.Sudoku_Cell_Alts.EMPTY

		# Check if the puzzle still has a unique solution
		if _has_unique_solution():
			#_guess_grid[pos.y][pos.x] = Utilties.Sudoku_Cell_Alts.EMPTY
			removed += 1  # Successful removal
		else:
			cell.set_is_player_cell(false)
			#_player_grid[pos.y][pos.x] = backup  # Restore if removing breaks uniqueness

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

	#var backup1 : int
	#var backup2 : int
	var focus_1 : SudokuCellInfo
	var focus_2 : SudokuCellInfo
	for rcr_c_ in symmetric_pairs:
		var r1 = rcr_c_[0]
		var c1 = rcr_c_[1]
		var r2 = rcr_c_[2]
		var c2 = rcr_c_[3]
		#for r1, c1, r2, c2 in symmetric_pairs:
		if removed >= cells_to_remove:
			break
		focus_1 = _cells_grid[r1][c1]
		focus_2 = _cells_grid[r2][c2]
		#backup1 = _player_grid[r1][c1]
		#backup2 = _player_grid[r2][c2]
		#if backup1 == Utilties.Sudoku_Cell_Alts.EMPTY or backup2 == Utilties.Sudoku_Cell_Alts.EMPTY:
		if focus_1.is_player_cell() or focus_2.is_player_cell():
			continue # skip rest of THIS loop
		focus_1.set_is_player_cell(true)
		focus_2.set_is_player_cell(true)
		#_player_grid[r1][c1] = Utilties.Sudoku_Cell_Alts.EMPTY
		#_player_grid[r2][c2] = Utilties.Sudoku_Cell_Alts.EMPTY
		if _has_unique_solution():
		#if _has_unique_solution(_player_grid):
			#_guess_grid[r1][c1] = Utilties.Sudoku_Cell_Alts.EMPTY
			#_guess_grid[r2][c2] = Utilties.Sudoku_Cell_Alts.EMPTY
			if [[r1],[c1]] == [[r2],[c2]]:
				removed += 1
			else:
				removed += 2
		else:
			focus_1.set_is_player_cell(false)
			focus_2.set_is_player_cell(false)
			#_player_grid[r1][c1] = backup1
			#_player_grid[r2][c2] = backup2

#func _has_unique_solution(grid) -> bool: return _count_solutions(grid) == 1
func _has_unique_solution() -> bool: return _count_solutions() == 1

## Currently built assiming the "only 1 solution" algo is working. 
func _get_results() -> Utilties.Results:
	for row : Array in _cells_grid:
		for cell : SudokuCellInfo in row: 
			if !cell.is_solved():
				return Utilties.Results.INPROGRESS
	puzzle_complete.emit(Utilties.Results.WIN)
	return Utilties.Results.WIN

## Helper to check whether a number can be placed in a given cell. 
func _is_valid(cell: SudokuCellInfo, num: int, for_solver := false) -> bool:
	var col_i: int = cell.get_position().x
	var row_i: int = cell.get_position().y
	var focus_cell : SudokuCellInfo
	## check all cells left and right
	for _col: int in range(get_cells_grid()[row_i].size()):
		if _col != col_i:
			focus_cell = get_cells_grid()[row_i][_col]
			if for_solver: 
				if focus_cell.get_button_value() == num:
					return false
			else:
				if focus_cell.get_solution_value() == num:
					return false
	## check all cells up and down
	for _row: int in range(get_cells_grid().size()):
		if _row != row_i:
			focus_cell = get_cells_grid()[_row][col_i]
			if for_solver: 
				if focus_cell.get_button_value() == num:
					return false
			else:
				if focus_cell.get_solution_value() == num:
					return false
	var box_row_start: int = row_i - (row_i % _subgrid_size.y)
	var box_col_start: int = col_i - (col_i % _subgrid_size.x)
	for __row in range(_subgrid_size.y):
		for __col in range(_subgrid_size.x):
			focus_cell = get_cells_grid()[__row + box_row_start][__col + box_col_start]
			if for_solver: 
				if focus_cell.get_button_value() == num:
					return false
			else:
				if focus_cell.get_solution_value() == num:
					return false
	return true

## Select the difficulty level and return the number of FILLED in values.
func _get_difficulty_count(difficulty: Utilties.Difficulty) -> int:
	var cell_count : int = _grid_size.x * _grid_size.y
	match difficulty:
		Utilties.Difficulty.DEBUG:
			return cell_count - 1
		Utilties.Difficulty.EASY:
			@warning_ignore("integer_division")
			return ceili(cell_count * .45) # 40
		Utilties.Difficulty.MEDIUM:
			@warning_ignore("integer_division")
			return ceili(cell_count * .35) # 35
		_: 
			@warning_ignore("integer_division")
			return ceili(cell_count * .30) # 30

func print_cells() -> void:
	var text : String 
	for row: Array in _cells_grid:
		text = "|"
		for cell: SudokuCellInfo in row: 
			text += str( cell._solution_value)
			text += "|"
		print(text)
	#var text : String 
	for row: Array in _cells_grid:
		text = "|"
		for cell: SudokuCellInfo in row: 
			text += str( cell.get_button_text())
			text += "|"
		print(text)

func _solver(count: Array, cap: int) -> void:
	if count[0] >= cap:
		return
	for row: Array in get_cells_grid():
		for cell : SudokuCellInfo in row:
			if !cell.has_guess():
				for num in _initial_domain:
					if _is_valid(cell, num, true):
						cell.set_guess_value(num)
						_solver(count, cap) ## This floating function and it's incramenting the count is what gets the multi solution magic 
						cell.clear_guess()
						if count[0] >= cap:
							return
				return
	count[0] += 1

## "is this unique" helper
func _count_solutions(cap=2) -> int:
	var count = [0]
	_solver(count, cap)
	return count[0]
