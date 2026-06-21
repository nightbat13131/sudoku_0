
# Abhrankan-Chakrabarti/sudoku.py
# https://gist.github.com/Abhrankan-Chakrabarti/abd3cc2a71a03ea56b3a464d4ce17e72
# no licence listed


extends Node

class_name Sudoku_AC

var _initial_domain : Array # int
const NROWS = 9
const NCOLS = 9
const SQR_SIZE = 3
var domains
var constraints
var sorted_cells
var rng

var _grid_size: Vector2i : get = get_grid_size , set = _set_grid_size
var _subgrid_size : Vector2i : set = _set_subgrid_size
var _player_grid : Array[Array]
var _solution_grid : Array[Array]

## Generate a new game state.
func new_game(grid_size: Vector2i, subgrid_size: Vector2i, difficlty : Utilties.Difficulty):
	_set_grid_size(grid_size)
	_set_subgrid_size(subgrid_size)
	assert(0 == grid_size.x % subgrid_size.x)
	assert( 0 == grid_size.y % subgrid_size.y)
	_generate_full_grid_solution()
	_remove_cells(_select_difficulty(difficlty))
	#await self.get_tree().process_frame
	#display_grid(_solution_grid, "Solution")
	#display_grid(_player_grid, "player")

## Select the difficulty level and return the number of blanks.
func _select_difficulty(difficulty: Utilties.Difficulty) -> int:
	var row_count : int = _initial_domain.max()
	match difficulty:
		Utilties.Difficulty.EASY:
			@warning_ignore("integer_division")
			return row_count ** 2 / 4
		Utilties.Difficulty.MEDIUM:
			@warning_ignore("integer_division")
			return row_count ** 2 / 3
		_: 
			@warning_ignore("integer_division")
			return row_count ** 2 / 2

## set the Sudoku puzzle size
func _set_grid_size(grid_size: Vector2i, ) -> void: 
	_grid_size = grid_size
	_initial_domain = range(1,max(_grid_size.x, _grid_size.y)+1)

func get_grid_size() -> Vector2i: return _grid_size

func _set_subgrid_size(subgrid_size: Vector2i) -> void: _subgrid_size = subgrid_size

## Generate a complete Sudoku grid.
func _generate_full_grid_solution() -> void:
	_solution_grid.clear()
	for y in range(_grid_size.y):
		_solution_grid.append([])
		for x in range(_grid_size.x):
			_solution_grid[y].append(0)
	for y in range(_grid_size.y):
		_fill_row_random(y)
	return
	#for y_ in range(0, _grid_size.y, _subgrid_size.y):
		#for x_ in range(0, _grid_size.x, _subgrid_size.x):
			#_fill_subgrid_random(y_, x_)
			
			
	#if solve_sudoku():
		#return grid

## Fill a subgrid with random numbers.
func _fill_row_random(row, max_tries := 4) -> void:
	if max_tries == 0: return
	var nums : Array = _initial_domain.duplicate()
	nums.shuffle()
	var match_found: = false
	for x: int in range(_grid_size.x):
		match_found = false
		for try_num: int in nums: 
			if !match_found:
				if is_safe(_solution_grid, Vector2i(x, row), try_num, "(" + str(x) + " " + str(row) + ") ?" + str(try_num) + "? "):
					nums.erase(try_num)
					_solution_grid[row][x] = try_num
					match_found = true
					break
			# no number found, retry row
		
		if !match_found:
			if max_tries > 1:
				prints("*********************", row, max_tries)
				for _x: int in range(_grid_size.x):
					_solution_grid[row][_x] = 0
				_fill_row_random(row, max_tries -1)


### Fill a subgrid with random numbers.
#func _fill_subgrid_random(row, col) -> void:
	#var nums : Array = _initial_domain.duplicate()
	#nums.shuffle()
	##var try_num : int
	#for y_: int in range(row, row + _subgrid_size.y):
		#for x_: int in range(col, col + _subgrid_size.x):
			#for try_num: int in nums: 	
				#if is_safe(_solution_grid, Vector2i(x_, y_), try_num):
					#nums.erase(try_num)
					#_solution_grid[y_][x_] = try_num
					#break

## Remove cells from the grid to create the puzzle.
func _remove_cells(blanks: int) -> void:
	_player_grid = _solution_grid.duplicate(true)
	#puzzle : Array = [row[:] for row in grid]
	var indices : Array[Vector2i] = []
	for row in _grid_size.y:
		for col in _grid_size.x:
			indices.append(Vector2i(col, row))
		 #= [(row, col) for row in range(M) for col in range(M)]
	indices.shuffle()
	var pos : Vector2i
	for _z in range(blanks):
		pos = indices.pop_back()
		_player_grid[pos.y][pos.x] = 0

## Check if it's safe to place a number in a specific cell.
func is_safe(grid: Array, pos: Vector2i, num: int, _debug_string:= "") -> bool:
	# Check the row and column
	var row: int = pos.y
	var col: int = pos.x
	for _x_ : int in range(_grid_size.y):
		if grid[row][_x_] == num:
			if _debug_string: prints(_debug_string, "-", _x_, row)
			return false
	for _y_ : int in range(_grid_size.y):
		if grid[_y_][col] == num:
			if _debug_string: prints(_debug_string, "|", col, _y_)
			return false
	#prints("(", col, row, ") {", num ,"}"   )
	# Check the subgrid
	var startRow := row - row % _subgrid_size.y
	var startCol := col - col % _subgrid_size.x
	for y_ in range(_subgrid_size.y):
		for x_ in range(_subgrid_size.x):
			if grid[y_ + startRow][x_ + startCol] == num:
				if _debug_string: prints(_debug_string, [y_ + startRow],[x_ + startCol])
				#print("_______")
				return false
	#print("_____________")
	return true

## Solve the Sudoku puzzle using backtracking.
func solve_sudoku(row=0, col=0, step_by_step := false) -> bool:
	if row == _grid_size.y and col == _grid_size.x:
		return true
	if col == _grid_size.x:
		row += 1
		col = 0
	if _player_grid[row][col] > 0:
		return await solve_sudoku(row, col + 1, step_by_step)

	for num in _initial_domain:
		if is_safe(_player_grid, Vector2i(col, row), num):
			_player_grid[row][col] = num

			if step_by_step:
				#display_grid(_grid, "Step-by-Step Solving (Placed {num} at {row + 1}, {col + 1})", initial_grid)
				await get_tree().create_timer(.5).timeout
			if await solve_sudoku(row, col + 1, step_by_step):
				return true
			_player_grid[row][col] = 0
			if step_by_step:
				#display_grid("Backtracking from {row + 1}, {col + 1}")
				await get_tree().create_timer(.5).timeout
	return false

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

## Check if the current grid matches the solution.
func check_solution() -> bool:
	for y in range(_grid_size.y):
		for x in range(_grid_size.x):
			if _player_grid[y][x] != _solution_grid[y][x]:
				return false
	return true

## Interactive gameplay for Sudoku.
func play_sudoku():
	pass
	"""
	while True:
		display_grid(grid, M, "Interactive Puzzle", initial_grid)
		choice = input("Enter 'move' to play, 'reset' to reset a move, 'restart' to restart from the beginning, 'hint' for a hint, 'check' to verify, 'save' to save here, or 'exit' to quit: ").strip().lower()

		if choice == 'move':
			try:
				row = int(input("Enter row (1 to M): ")) - 1
				col = int(input("Enter column (1 to M): ")) - 1
				num = int(input(f"Enter number (1 to {M}): "))

				if initial_grid[row][col] != 0:
					print("You cannot change the initial numbers.")
				elif is_safe(grid, M, row, col, num):
					grid[row][col] = num
					print(f"Placed {num} at ({row + 1}, {col + 1})")
				else:
					print("Invalid move. The number violates Sudoku rules.")
			except (ValueError, IndexError):
				print("Invalid input. Please try again.")

		elif choice == 'reset':
			try:
				row = int(input("Enter row (1 to M): ")) - 1
				col = int(input("Enter column (1 to M): ")) - 1

				if initial_grid[row][col] != 0:
					print("You cannot reset the initial numbers.")
				else:
					grid[row][col] = 0
			except (ValueError, IndexError):
				print("Invalid input. Please try again.")

		elif choice == 'restart':
			grid = [row[:] for row in initial_grid]

		elif choice == 'hint':
			hint_given = False
			for row in range(M):
				for col in range(M):
					if grid[row][col] == 0:
						grid[row][col] = solution[row][col]
						print(f"Hint: Placed {solution[row][col]} at ({row + 1}, {col + 1})")
						display_grid(grid, M, "Interactive Puzzle", initial_grid)
						hint_given = True
						break
				if hint_given:
					break

		elif choice == 'check':
			if check_solution(grid, solution, M):
				display_grid(grid, M, "Solved Puzzle", initial_grid)
				print("Congratulations! You've completed the Sudoku puzzle correctly!")
				break
			else:
				print("The puzzle is not complete or contains errors.")
		else:
			print("Invalid option. Please try again.")
	"""

## Main function to run the Sudoku game.
"""
func main():
	M = int(input("Enter grid size (4 for 4x4, 9 for 9x9): "))
	choice = input("Do you want to (1) Enter a puzzle, (2) Generate a random puzzle, or (3) Play interactively? Enter 1, 2, or 3: ")
	#if choice == '3':
	#	play = input("Do you want to (1) Play a new game, or (2) Play a saved game? Enter 1, or 2: ")
	if choice == '1':
		grid = interactive_input(M)
		initial_grid = [row[:] for row in grid]
	elif choice == '3' and play == '2':
		full_grid, grid, initial_grid, title = load_game(M)
		display_grid(grid, M, title, initial_grid)
	elif choice == '2' or choice == '3':
		full_grid, grid, initial_grid, title = new_game(M)
		display_grid(grid, M, title, initial_grid)
	
	if choice == '1' or choice == '2':
		step_by_step = input("Show step-by-step solving process? (yes/no): ").strip().lower() == 'yes'
		if solve_sudoku(grid, M, step_by_step=step_by_step, initial_grid=initial_grid):
			display_grid(grid, M, "Solved Puzzle", initial_grid)
		else:
			print("No solution exists for this puzzle.")
	elif choice == '3':
		play_sudoku(grid, M, full_grid, initial_grid)
"""

#if __name__ == "__main__":
	#while True:
		#main()
		#again = input("Would you like to solve another puzzle? (yes/no): ").strip().lower()
		#if again != 'yes':
			#print("Thank you for playing! Goodbye.")
			#break
