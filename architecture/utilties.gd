class_name Utilties extends RefCounted

const SODOKU_GUESS = &"Sudoku Guess"
const SUDOKU_HINT = &"Sudoku Hint"
const MINESWEEPER_POKE = &"MineSweeper"

const COLOR_SUBGRID_HIGHLIGHT : Color = Color(1, 1, 1)
const COLOR_SUBGRID_LOWLIGHT : Color = Color(.7, .7, .7,)

enum Difficulty {EASY = 0, MEDIUM = 1, HARD = 2, DEBUG = -1}

enum Results {INPROGRESS = 0, WIN = 1, LOSS = 2}

## valid SUDOCU cell values are 1+. Map out the meaing of alternate values.
enum Sudoku_Cell_Alts {EMPTY = 0, GUESS_BLOCKED = -1 }

enum SudokuMode {NUMBERS = 0, ICONS = 1}

enum MineSweeper_Cells_Alts {EMPTY = 0, BOMB = -12, FLAG = -13, NO_GUESS = -14, PRESS = -15}

enum PathSweeper_Alts { MOVE = -1, REPELL = -2, FLAG0 = -3, FLAG1 = -4, # Used in UI, so don't change
	NA = 0, 
	BLOCKED  = 5, REPELL_SUCCESS = 6, REPELL_WASTED = 7,
	DANGER0 = 10,
	LOOT0 = 20,
	WALL = 30, BOULDER = 31
	}

## Display the grid with row and column numbers.
static func display_grid(grid : Array[Array], title="Grid"):
	print(title)
	var row : Array
	var row_print := ""
	#var cell : int
	for y in range(grid.size()):
		row = grid[y]
		row_print = str(y) + "| "
		for cell: PuzzleCellInfo in row:
			row_print += str(cell)
		row_print += " | "
		print(row_print)
