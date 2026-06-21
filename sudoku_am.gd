# https://github.com/alicommit-malp/sudoku/blob/main/README.md
# MIT licence 
# https://github.com/alicommit-malp/sudoku/blob/main/puzzle_generator.py

class_name Sudoku extends Resource

signal puzzle_generated


var _initial_domain : Array # Range does not return a type array

@export var _grid_size: Vector2i #: get = get_grid_size , set = _set_grid_size
@export var _subgrid_size : Vector2i # : set = _set_subgrid_size
@export var _difficulty := Utilties.Difficulty.EASY
var _player_grid : Array[Array]
var _solution_grid : Array[Array]
var _guess_grid : Array[Array]

var _tick_tracker : int

func get_player_grid() -> Array[Array] : return _player_grid

func get_domain_max() -> int: return _initial_domain.max()

func get_subgrid_count() -> int: return (_grid_size.x % _subgrid_size.x) * (_grid_size.y % _subgrid_size.y)

func generate_next_puzzle() -> bool: 
	_tick_tracker = Time.get_ticks_msec()
	await _new_game(_grid_size, _subgrid_size, _difficulty)
	puzzle_generated.emit()
	return true

## Generate a new game state.
func _new_game(grid_size: Vector2i, subgrid_size: Vector2i, difficlty : Utilties.Difficulty) -> bool:
	_set_grid_size(grid_size)
	assert(0 == grid_size.x % subgrid_size.x)
	assert( 0 == grid_size.y % subgrid_size.y)
	_generate_puzzle_task(_get_difficulty_count(difficlty), [true, false].pick_random())
	return true

func _generate_puzzle_task(min_clues: int, use_symmetry = true) -> void:
	_generate_professional_sudoku(min_clues, use_symmetry)

func _generate_professional_sudoku(min_clues := 30, symmetry := false) -> void:
	_player_grid.clear()
	_solution_grid.clear()
	_guess_grid.clear()
	for y: int in range(_grid_size.y):
		_solution_grid.append([])
		for x: int in range(_grid_size.x):
			_solution_grid[y].append(0)
	_guess_grid = _solution_grid.duplicate(true)
	_fill_solution()
	#display_grid(_solution_grid)
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
	#display_grid(_player_grid, "Player")


	# Remove numbers to leave exactly num_clues in the grid
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
		if backup == 0:
			continue
		_player_grid[pos.y][pos.x] = 0

		# Check if the puzzle still has a unique solution
		if _has_unique_solution(_player_grid):
			removed += 1  # Successful removal
		else:
			_player_grid[pos.y][pos.x] = backup  # Restore if removing breaks uniqueness


const r1 = 0
const c1 = 1
const r2 = 2
const c2 = 3
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
		#for r1, c1, r2, c2 in symmetric_pairs:
		if removed >= cells_to_remove:
			break
		backup1 = _player_grid[rcr_c_[r1]][rcr_c_[c1]]
		backup2 = _player_grid[rcr_c_[r2]][rcr_c_[c2]]
		if backup1 == 0 or backup2 == 0:
			continue # skip rest of THIS loop
		_player_grid[rcr_c_[r1]][rcr_c_[c1]] = 0
		_player_grid[rcr_c_[r2]][rcr_c_[c2]] = 0
		if _has_unique_solution(_player_grid):
			if [[rcr_c_[r1]],[rcr_c_[c1]]] == [[rcr_c_[r2]],[rcr_c_[c2]]]:
				removed += 1
			else:
				removed += 2
		else:
			_player_grid[rcr_c_[r1]][rcr_c_[c1]] = backup1
			_player_grid[rcr_c_[r2]][rcr_c_[c2]] = backup2

func _has_unique_solution(grid) -> bool: return _count_solutions(grid) == 1

func _count_solutions(grid, cap=2) -> int:
	var count = [0]
	_solve(grid.duplicate(true), count, cap)
	return count[0]

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
			if _solution_grid[row][col] == 0:
				num_list = _initial_domain.duplicate()
				num_list.shuffle()
				for num: int in num_list:
					if _is_valid(_solution_grid, row, col, num):
						_solution_grid[row][col] = num
						if _fill_solution():
							return true
						_solution_grid[row][col] = 0
				return false
	return true

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

## set the Sudoku puzzle size
func _set_grid_size(grid_size: Vector2i, ) -> void: 
	_grid_size = grid_size
	_initial_domain = range(1,max(_grid_size.x, _grid_size.y)+1)

func get_grid_size() -> Vector2i: return _grid_size

func get_subgrid_size() -> Vector2: return _subgrid_size

## Display the Sudoku grid with row and column numbers.
func display_grid(grid : Array[Array], title="Sudoku Grid"):
	print(title)
	
	#print("   ", " | ".join(str(i + 1) for i in range()))
	#print("   " + "-" * (4 * M - 1))
	var row : Array
	var row_print := ""
	var cell : int
	for y in range(grid.size()):
		row = grid[y]
		row_print = str(y) + "| "
	#for i, row in enumerate(grid):
		#print(f"{i + 1} |", end=" ")
		for j in range(row.size()):
		#for j, cell in enumerate(row):
			cell = row[j]
			if cell > 0:
				row_print += str(cell)
			else: 
				row_print += "."
			row_print += " | "
			#if initial_grid and initial_grid[i][j] != 0:
			#	print("\033[97m{cell if cell != 0 else '.'}\033[0m", end=" | ")
			#else:
			#	print(f"\033[92m{cell if cell != 0 else '.'}\033[0m", end=" | ")
		print(row_print)
