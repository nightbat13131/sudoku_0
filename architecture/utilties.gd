class_name Utilties extends RefCounted

const SODOKU_GUESS = &"Sudoku Guess"
const SUDOKU_HINT = &"Sudoku Hint"
const INPUT_UNDO = &"input_undo"
const INPUT_REDO = &"input_redo"

const COLOR_SUBGRID_HIGHLIGHT : Color = Color(1, 1, 1)
const COLOR_SUBGRID_LOWLIGHT : Color = Color(.7, .7, .7,)


enum Difficulty {EASY = 0, MEDIUM = 1, HARD = 2}

## valid SUDOCU cell values are 1+. Map out the meaing of alternate values.
enum Sudoku_Cell_Alts {EMPTY = 0, GUESS_BLOCKED = -1 }

enum SudokuMode {NUMBERS = 0, ICONS = 1}

enum MineSweeper_Cells_Alts {EMPTY = 0, BOMB = -12, FLAG = -13, NO_GUESS = -14}

## Display the grid with row and column numbers.
static func display_grid(grid : Array[Array], title="Grid"):
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
				match cell:
					MineSweeper_Cells_Alts.BOMB:
						row_print += "X"
					_: 
						row_print += "."
			row_print += " | "
		print(row_print)
